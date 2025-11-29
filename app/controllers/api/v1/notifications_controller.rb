module Api
  module V1
    class NotificationsController < BaseController
      # GET /api/v1/users/:rut/notifications
      def index
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end

        notifications = user.notifications.recent

        render json: {
          success: true,
          notifications: notifications.map(&:as_json_for_api),
          unread_count: user.notifications.unread.count
        }, status: :ok
      end

      # PUT /api/v1/notifications/:id/read
      def mark_as_read
        notification = Notification.find_by(id: params[:id])

        unless notification
          return render json: {
            success: false,
            message: 'notification_not_found',
            error_code: 'NOTIFICATION_NOT_FOUND'
          }, status: :not_found
        end

        notification.mark_as_read!

        render json: {
          success: true,
          message: 'Notificación marcada como leída'
        }, status: :ok
      end

      # PUT /api/v1/users/:rut/notifications/read_all
      def mark_all_as_read
        user = User.find_by(rut: format_rut(params[:rut]))
        
        unless user
          return render json: {
            success: false,
            message: 'user_not_found',
            error_code: 'USER_NOT_FOUND'
          }, status: :not_found
        end

        user.notifications.unread.update_all(read: true)

        render json: {
          success: true,
          message: 'Todas las notificaciones marcadas como leídas'
        }, status: :ok
      end

      private

      def format_rut(rut)
        return nil if rut.blank?
        rut.to_s.gsub(/[^0-9kK]/, '').upcase
      end
    end
  end
end
