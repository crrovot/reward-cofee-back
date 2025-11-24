module Api
  module V1
    class RewardsController < BaseController
      # POST /api/v1/rewards/redeem
      def redeem
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found'
          }, status: :not_found
        end
        
        available_stamps = user.stamps_paid - user.rewards_used
        
        if available_stamps <= 0
          return render json: {
            success: false,
            message: 'insufficient_stamps'
          }, status: :bad_request
        end
        
        if user.update(rewards_used: user.rewards_used + 1)
          render json: {
            success: true,
            message: 'reward_redeemed',
            user: {
              stamps_paid: user.stamps_paid,
              rewards_used: user.rewards_used,
              rewards_available: user.stamps_paid - user.rewards_used
            }
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'error redeeming reward'
          }, status: :bad_request
        end
      end
      
      private
      
      def format_rut(rut)
        return nil if rut.blank?
        rut.to_s.gsub(/[^0-9kK]/, '').upcase
      end
    end
  end
end
