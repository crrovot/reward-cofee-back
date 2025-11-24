module Api
  module V1
    class AuthController < BaseController
      # POST /api/v1/auth/login
      def login
        rut = params[:rut]
        email = params[:email]
        
        if rut.blank? && email.blank?
          return render json: { 
            success: false, 
            message: 'rut or email is required' 
          }, status: :bad_request
        end
        
        user = User.find_by_credentials(rut: rut, email: email)
        
        if user
          render json: {
            success: true,
            user: user_response(user),
            token: generate_token(user)
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'user_not_found',
            redirect: '/registro'
          }, status: :not_found
        end
      rescue => e
        Rails.logger.error "Login error: #{e.message}"
        render json: {
          success: false,
          message: 'internal_error'
        }, status: :internal_server_error
      end
      
      # POST /api/v1/auth/register
      def register
        # Verificar si el usuario ya existe pero no está registrado completamente
        existing_user = User.find_by(rut: format_rut_clean(params[:rut]))
        
        if existing_user && !existing_user.email.present?
          # Usuario existe por compras previas pero no se había registrado
          if existing_user.update(user_params.merge(registered: true, password: SecureRandom.hex(16)))
            return render json: {
              success: true,
              message: 'welcome_back',
              user: user_response(existing_user),
              has_previous_purchases: existing_user.purchases.any?,
              token: generate_token(existing_user)
            }, status: :ok
          end
        end
        
        user = User.new(user_params)
        user.password = SecureRandom.hex(16) # Password temporal
        
        if user.save
          render json: {
            success: true,
            user: user_response(user),
            token: generate_token(user)
          }, status: :created
        else
          if user.errors[:rut].include?('has already been taken') || 
             user.errors[:email].include?('has already been taken')
            render json: {
              success: false,
              message: 'user_already_exists'
            }, status: :conflict
          else
            render json: {
              success: false,
              message: 'validation failed',
              errors: user.errors.messages
            }, status: :bad_request
          end
        end
      end
      
      private
      
      def user_params
        params.permit(:rut, :name, :email, :address, :country, :region, :phone)
      end
      
      def user_response(user)
        {
          id: user.rut,
          rut: format_rut_display(user.rut),
          name: user.name,
          email: user.email,
          address: user.address,
          country: user.country,
          region: user.region,
          phone: user.phone,
          registered: user.registered,
          discountPct: user.discount_pct,
          stampsPaid: user.stamps_paid,
          rewardsUsed: user.rewards_used
        }.compact
      end
      
      def format_rut_display(rut)
        return rut if rut.blank?
        clean = rut.gsub(/[^0-9kK]/, '')
        "#{clean[0..-2]}-#{clean[-1]}"
      end
      
      def format_rut_clean(rut)
        return nil if rut.blank?
        rut.to_s.gsub(/[^0-9kK]/, '').upcase
      end
      
      def generate_token(user)
        payload = {
          user_id: user.id,
          rut: user.rut,
          exp: 30.days.from_now.to_i
        }
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end
