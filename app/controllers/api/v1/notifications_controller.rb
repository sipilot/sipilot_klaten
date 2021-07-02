class Api::V1::NotificationsController < Api::BaseController
  def index
    notifications = current_user_api.recipients.where('read_at IS NULL').order('created_at desc').map do |notif|
      {
        id: notif.id,
        title: notif.title,
        message: notif.message,
        type: notif.notif_type,
        action: notif.action,
        notifiable_id: notif.notifiable_id,
        notifiable_type: notif.notifiable_type,
        read_at: Formatter.date_dmy(notif.read_at)
      }
    end
    api_success_response(notifications)
  end

  def detail
    notification = Notification.find_by(id: params['id'])
    return api_error_response(['Notification not found.']) unless notification

    result = {
      id: notification.id,
      title: notification.title,
      action: notification.action,
      message: notification.message,
      notifiable_id: notification.notifiable_id,
      notifiable_type: notification.notifiable_type,
      read_at: Formatter.date_dmy(notification.read_at)
    }
    api_success_response(result)
  end

  def read
    notification = current_user_api.recipients.find_by(id: params['id'])
    if notification
      notification.update(read_at: Time.now)
      api_success_response({ message: 'Success read notification.' })
    else
      api_error_response(['Notification not found'])
    end
  end
end
