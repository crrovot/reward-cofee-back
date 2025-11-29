module Api
  module V1
    class UsersController < BaseController
      # GET /api/v1/users/:rut/stamps
      def stamps
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        total_purchases = user.purchases.count
        stamps_earned = total_purchases % 10
        rewards_available = user.stamps_paid - user.rewards_used
        
        render json: {
          success: true,
          stamps_earned: stamps_earned,
          stamps_total: 10,
          next_reward: "Café Gratis",
          rewards_available: rewards_available
        }, status: :ok
      end

      # GET /api/v1/users/:rut/stats
      def stats
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        purchases = user.purchases
        total_purchases = purchases.count
        last_purchase = purchases.order(created_at: :desc).first
        
        render json: {
          success: true,
          user: {
            rut: format_rut_display(user.rut),
            name: user.name,
            total_points: user.total_points,
            stamps_paid: user.stamps_paid,
            rewards_used: user.rewards_used,
            discount_pct: user.discount_pct
          },
          stats: {
            total_purchases: total_purchases,
            total_spent: purchases.sum(:amount).to_f,
            average_purchase: total_purchases > 0 ? (purchases.sum(:amount) / total_purchases).to_f.round(2) : 0,
            last_purchase_date: last_purchase&.created_at&.iso8601,
            next_reward_in: 10 - (total_purchases % 10)
          }
        }, status: :ok
      end

      # PUT /api/v1/users/:rut
      def update
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end

        if user.update(user_update_params)
          render json: {
            success: true,
            message: 'Perfil actualizado correctamente',
            user: {
              rut: format_rut_display(user.rut),
              name: user.name,
              email: user.email,
              phone: user.phone,
              address: user.address
            }
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Error al actualizar perfil',
            errors: user.errors.messages
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/users/:rut/qr
      def qr
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end

        qr_data = user.generate_qr_token!
        
        # Generar QR code como base64
        qr_content = "REWARD_COFFEE:#{qr_data[:token]}"
        qr_code = generate_qr_base64(qr_content)
        
        render json: {
          success: true,
          qr_code: qr_code,
          qr_token: qr_data[:token],
          expires_at: qr_data[:expires_at].iso8601
        }, status: :ok
      end

      # GET /api/v1/users/:rut/redemptions
      def redemptions
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end

        redemptions = user.redemptions.recent.includes(:reward)

        render json: {
          success: true,
          redemptions: redemptions.map(&:as_json_for_api)
        }, status: :ok
      end
      
      private
      
      def format_rut(rut)
        return nil if rut.blank?
        rut.to_s.gsub(/[^0-9kK]/, '').upcase
      end
      
      def format_rut_display(rut)
        return rut if rut.blank?
        clean = rut.gsub(/[^0-9kK]/, '')
        "#{clean[0..-2]}-#{clean[-1]}"
      end

      def user_update_params
        params.permit(:name, :email, :phone, :address)
      end

      def generate_qr_base64(content)
        # Placeholder - en producción usar gem 'rqrcode'
        # Por ahora retornamos un placeholder con el contenido codificado
        require 'base64'
        Base64.strict_encode64("QR:#{content}")
      end
    end
  end
end
