module Api
  module V1
    class RewardsController < BaseController
      # GET /api/v1/rewards
      def index
        rewards = Reward.active.ordered
        
        # Si no hay rewards en DB, usar datos por defecto
        if rewards.empty?
          rewards_data = default_rewards
        else
          rewards_data = rewards.map(&:as_json_for_api)
        end
        
        render json: {
          success: true,
          rewards: rewards_data
        }, status: :ok
      end

      # POST /api/v1/rewards/redeem
      def redeem
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        available_stamps = user.stamps_paid - user.rewards_used
        
        if available_stamps <= 0
          return render json: {
            success: false,
            message: 'insufficient_stamps',
            error_code: 'INSUFFICIENT_STAMPS'
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

      # POST /api/v1/users/:rut/redeem
      def redeem_by_user
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end
        
        reward_id = params[:reward_id].to_i
        reward = Reward.active.find_by(id: reward_id)
        
        # Fallback a datos por defecto si no hay rewards en DB
        unless reward
          rewards_data = {
            1 => { name: "Café Americano Gratis", stamps_required: 10 },
            2 => { name: "Postre Gratis", stamps_required: 15 },
            3 => { name: "Combo Especial", stamps_required: 20 }
          }
          reward_info = rewards_data[reward_id]
          
          unless reward_info
            return render json: {
              success: false,
              message: 'reward_not_found',
              error_code: 'REWARD_NOT_FOUND'
            }, status: :not_found
          end
        end
        
        total_purchases = user.purchases.count
        current_stamps = total_purchases % 10
        stamps_required = reward&.stamps_required || reward_info[:stamps_required]
        reward_name = reward&.name || reward_info[:name]
        
        if current_stamps < stamps_required
          return render json: {
            success: false,
            message: 'insufficient_stamps',
            error_code: 'INSUFFICIENT_STAMPS',
            stamps_needed: stamps_required - current_stamps
          }, status: :bad_request
        end
        
        # Crear registro de redención
        redemption_code = SecureRandom.alphanumeric(6).upcase
        
        if reward
          redemption = user.redemptions.create!(
            reward: reward,
            redemption_code: redemption_code,
            status: 'pending'
          )
        end
        
        if user.update(rewards_used: user.rewards_used + 1)
          new_stamps = current_stamps - stamps_required
          new_stamps = 0 if new_stamps < 0
          
          render json: {
            success: true,
            message: '¡Recompensa canjeada exitosamente!',
            new_stamps: new_stamps,
            redemption_code: redemption_code,
            reward: {
              id: reward_id,
              name: reward_name
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

      def default_rewards
        [
          {
            id: 1,
            name: "Café Americano Gratis",
            description: "Un café americano de cualquier tamaño",
            stamps_required: 10,
            image_url: "/images/rewards/americano.jpg"
          },
          {
            id: 2,
            name: "Postre Gratis",
            description: "Postre a elección de nuestra carta",
            stamps_required: 15,
            image_url: "/images/rewards/postre.jpg"
          },
          {
            id: 3,
            name: "Combo Especial",
            description: "Café + Postre de tu elección",
            stamps_required: 20,
            image_url: "/images/rewards/combo.jpg"
          }
        ]
      end
    end
  end
end
