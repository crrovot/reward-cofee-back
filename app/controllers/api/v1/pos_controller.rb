module Api
  module V1
    class PosController < BaseController
      # POST /api/v1/pos/scan
      # Endpoint para el sistema POS - registra compra al escanear QR del cliente
      def scan
        qr_token = params[:qr_token]
        location_id = params[:location_id]
        amount = params[:amount].to_f
        stamps_to_add = params[:stamps_to_add] || 1

        # Validar parámetros
        if qr_token.blank?
          return render json: {
            success: false,
            message: 'QR token requerido',
            error_code: 'MISSING_QR_TOKEN'
          }, status: :bad_request
        end

        # Buscar usuario por QR token
        user = User.find_by_qr_token(qr_token)

        unless user
          return render json: {
            success: false,
            message: 'QR inválido o expirado',
            error_code: 'INVALID_QR_TOKEN'
          }, status: :unauthorized
        end

        # Obtener ubicación
        location = Location.find_by(id: location_id)
        location_name = location&.name || "Sucursal Principal"

        # Crear la compra
        purchase = user.purchases.create!(
          amount: amount,
          location: location_name,
          location_id: location_id,
          stamps_earned: stamps_to_add,
          points_earned: (amount / 100).floor
        )

        # Actualizar estadísticas del usuario
        user.add_stamps(stamps_to_add)
        user.add_points(purchase.points_earned)
        user.save!

        # Invalidar el QR token después de usar
        user.update!(qr_token: nil, qr_token_expires_at: nil)

        # Crear notificación de nuevo stamp
        Notification.create_new_stamp(user)

        # Verificar si el usuario tiene una nueva recompensa disponible
        total_purchases = user.purchases.count
        if total_purchases % 10 == 0
          Notification.create_reward_available(user, "Café Gratis")
        end

        render json: {
          success: true,
          message: 'Compra registrada exitosamente',
          purchase: {
            id: purchase.id,
            amount: purchase.amount.to_f,
            stamps_earned: purchase.stamps_earned,
            points_earned: purchase.points_earned,
            location: location_name,
            date: purchase.created_at.iso8601
          },
          user: {
            rut: format_rut_display(user.rut),
            name: user.name,
            total_stamps: user.purchases.count % 10,
            rewards_available: user.stamps_paid - user.rewards_used
          }
        }, status: :created
      end

      private

      def format_rut_display(rut)
        return rut if rut.blank?
        clean = rut.gsub(/[^0-9kK]/, '')
        "#{clean[0..-2]}-#{clean[-1]}"
      end
    end
  end
end
