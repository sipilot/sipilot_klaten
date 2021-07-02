class KasubsisController < ApplicationController
  layout 'dashboards'

  before_action :authenticate_user!
  before_action :set_ransact_value, only: [
    :index,
    :application_report
  ]

  def submission_approve
    submissions = Submission.where(id: submission_ses)
    if current_user.kasubsi_tematik?
      message = 'TERKIRIM KE ADMIN VALIDASI'
      notif_type = 'Selesai di Kasubsi Tematik'
      submissions.update(kasubsi_tematik_status: 'selesai', date_of_completion: Time.now)
    end

    if current_user.kasubsi_pendaftaran?
      message = 'TERKIRIM KE ADMIN BUKU TANAH'
      notif_type = 'Selesai di Kasubsi Pendaftaran'
      submissions.update(kasubsi_registration_status: 'selesai', date_of_completion: Time.now)
    end

    if current_user.kasubsi_pola_ruang?
      message = 'TERKIRIM KE ADMIN POLA RUANG'
      notif_type = 'Selesai di Kasubsi Pola Ruang'
      submissions.update(kasubsi_space_pattern_status: 'selesai', date_of_completion: Time.now)
    end

    submissions.each do |submission|
      send_notification(submission, notif_type, 'selesai', 'selesai di kasubsi.')
    end

    session[:submission_ids] = []
    session[:is_check_all] = false
    flash[:notice] = message
    redirect_to dashboards_kasubsi_path
  end

  def index
    @search = Submission.kasubsi_submission_todays(@role).ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])

    session[:return_back] = request.fullpath
    session[:all_submission_ids] = @search.result.pluck(:id).map(&:to_s)
  end

  def accept_submission
    @submission = Submission.find_by(id: params['id'])
    return redirect_to dashboards_kasubsi_path if @submission.nil?

    if current_user.kasubsi_tematik?
      @submission.update(kasubsi_tematik_status: 'selesai')
      @message = 'TERKIRIM KE ADMIN VALIDASI'
      notif_type = 'Selesai di Kasubsi Tematik'
    end

    if current_user.kasubsi_pendaftaran?
      @submission.update(kasubsi_registration_status: 'selesai')
      @message = 'TERKIRIM KE ADMIN BUKU TANAH'
      notif_type = 'Selesai di Kasubsi Pendaftaran'
    end

    if current_user.kasubsi_pola_ruang?
      @submission.update(kasubsi_space_pattern_status: 'selesai')
      @message = 'TERKIRIM KE ADMIN POLA RUANG'
      notif_type = 'Selesai di Kasubsi Pola Ruang'
    end

    @submission.update(date_of_completion: Time.now)

    send_notification(@submission, notif_type, 'selesai', 'selesai di kasubsi.')

    email = @submission.user.email
    id    = @submission.submission_code
    SubmissionMailer.with(id: id, email: email).submission_done.deliver_now

    @links = session[:return_back]
  end

  def send_notification(submission, notif_type, action, notes)
    title = "#{submission.submission_code} - #{notif_type}"
    email = submission.user.email
    notif = Notification.new
    notif.title         = title
    notif.message       = notes
    notif.action        = action
    notif.notifiable    = submission
    notif.actor_id      = current_user.id
    notif.recipient_id  = submission.user.id
    notif.notif_type    = submission.notif_type
    notif.save

    return unless action == 'revisi'

    SubmissionMailer.with(title: title, message: params['notes'], email: email).submission_revisions.deliver_now
  end

  def submission_detail
    @submission = Submission.find_by(id: params['id'])
  end

  def application_report
    @search = Submission.kasubsi_submission_report(@role).ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])
  end

  private

  def set_ransact_value
    @gteq_params = begin
                     params['q']['created_at_gteq']
                   rescue StandardError
                     ''
                   end
    @lteq_params = begin
                     params['q']['created_at_lteq']
                   rescue StandardError
                     ''
                   end
    @search_params = begin
                      params['q']['fullname_or_submission_code_cont']
                    rescue StandardError
                      ''
                    end
  end
end
