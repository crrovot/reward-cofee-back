module Api
  module V1
    class ContactController < BaseController
      # POST /api/v1/contact
      def create
        contact_message = ContactMessage.new(contact_params)

        if contact_message.save
          # Aquí podrías agregar envío de email al equipo de soporte
          # ContactMailer.new_message(contact_message).deliver_later

          render json: {
            success: true,
            message: 'Mensaje enviado correctamente. Te contactaremos pronto.'
          }, status: :created
        else
          render json: {
            success: false,
            message: 'Error al enviar el mensaje',
            errors: contact_message.errors.messages
          }, status: :unprocessable_entity
        end
      end

      private

      def contact_params
        params.permit(:name, :email, :message)
      end
    end
  end
end
