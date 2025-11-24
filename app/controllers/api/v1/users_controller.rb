module Api
  module V1
    class UsersController < BaseController
      # GET /api/v1/users/:rut/stats
      def stats
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found'
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
    end
  end
end
