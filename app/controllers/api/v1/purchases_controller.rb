module Api
  module V1
    class PurchasesController < BaseController
      before_action :find_user, only: [:create]
      
      # POST /api/v1/purchases
      def create
        user = User.find_by(rut: params[:rut])
        return render json: { success: false, message: 'Usuario no encontrado', error_code: 'USER_NOT_FOUND' }, status: :not_found unless user

        # Calcular total
        total = params[:items].sum { |item| item[:price] * item[:quantity] }

        # Calcular sellos y aplicar canje
        stamps_earned = params[:items].count { |item| item[:is_coffee] }
        freebies_used = 0
        if user.stamps + stamps_earned >= 7
          freebies_used = 1
          stamps_earned -= 7
          total -= params[:items].find { |item| item[:is_coffee] }[:price]
        end

        # Calcular puntos
        points_earned = (total * 0.01).to_i

        # Registrar compra
        purchase = user.purchases.create(
          total: total,
          points_earned: points_earned,
          stamps_earned: stamps_earned,
          freebies_used: freebies_used,
          items: params[:items]
        )

        # Actualizar usuario
        user.add_stamps(stamps_earned)
        user.add_points(points_earned)
        user.save

        render json: {
          success: true,
          purchase: {
            id: purchase.id,
            total: total,
            points_earned: points_earned,
            stamps_earned: stamps_earned,
            freebies_used: freebies_used
          },
          message: 'Compra registrada exitosamente'
        }
      end
      
      # GET /api/v1/users/:rut/purchases
      def index
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        page = (params[:page] || 1).to_i
        limit = (params[:limit] || params[:per_page] || 20).to_i
        limit = [limit, 100].min # Max 100 por página
        
        total_count = user.purchases.count
        total_pages = (total_count.to_f / limit).ceil
        
        paginated = user.purchases.recent.offset((page - 1) * limit).limit(limit)
        
        render json: {
          success: true,
          purchases: paginated.map { |p| purchase_response(p) },
          pagination: {
            page: page,
            limit: limit,
            total: total_count,
            totalPages: total_pages
          }
        }, status: :ok
      end

      # GET /api/v1/users/:rut/purchases/recent
      def recent
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        recent_purchases = user.purchases.recent.limit(5)
        
        render json: {
          success: true,
          purchases: recent_purchases.map { |p| recent_purchase_response(p) }
        }, status: :ok
      end
      
      private
      
      def find_user
        rut = format_rut(params[:rut])
        @user = User.find_by(rut: rut)
        
        unless @user
          render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
      end
      
      def purchase_params
        params.permit(:amount, :products)
      end
      
      def format_rut(rut)
        return nil if rut.blank?
        rut.to_s.gsub(/[^0-9kK]/, '').upcase
      end
      
      def purchase_response(purchase)
        {
          id: purchase.id,
          location: purchase.location || "Sucursal Principal",
          date: purchase.created_at.iso8601,
          amount: purchase.amount.to_f,
          points_earned: purchase.points_earned,
          stamps_earned: purchase.stamps_earned || 1,
          products: purchase.products
        }.compact
      end
      
      def user_stats_response(user)
        {
          total_points: user.total_points,
          stamps_paid: user.stamps_paid,
          rewards_available: user.stamps_paid - user.rewards_used
        }
      end
      
      def format_rut_display(rut)
        return rut if rut.blank?
        clean = rut.gsub(/[^0-9kK]/, '')
        "#{clean[0..-2]}-#{clean[-1]}"
      end

      def recent_purchase_response(purchase)
        {
          id: purchase.id,
          location: purchase.location || "Sucursal Principal",
          date: purchase.created_at.iso8601,
          stamps_earned: purchase.stamps_earned || 1
        }
      end
    end
  end
end
