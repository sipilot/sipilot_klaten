class AdminsController < ApplicationController
  layout 'dashboards'

  before_action :authenticate_user!
  before_action :set_submission, only: %i[
    member_revisions
    taken_submission
    accept_submission
    detail_submission
    process_member_revision
    process_taken_submission
    process_accept_submission
  ]
  before_action :set_ransact_value, only: %i[
    index
    counter
    revisions
    applications
  ]
  before_action :set_pagination_state, only: %i[
    index
    applications
    revisions
    counter
  ]

  def submission_approve
    submissions = Submission.where(id: submission_ses)
    if current_user.admin_buku_tanah?
      notif_type = 'Selesai di Admin Buku Tanah'
      message = 'BERKAS TERKIRIM KE KASUBSI PENDAFTARAN'
      submissions.update_all(land_book_status: 'selesai')
    end

    if current_user.admin_validasi?
      notif_type = 'Selesai di Admin Validasi'
      message = 'BERKAS TERKIRIM KE KASUBSI TEMATIK'
      submissions.update_all(submission_status: 'selesai')
    end

    if current_user.admin_pola_ruang?
      notif_type = 'Selesai di Admin Pola Ruang'
      message = 'BERKAS TERKIRIM KE KASUBSI POLA RUANG'
      submissions.update_all(space_pattern_status: 'selesai')
      submissions.admin_referral = params['admin_referral']
    end

    submissions.each do |submission|
      send_notification(submission, notif_type, 'selesai', params['notes'])
    end

    session[:submission_ids] = []
    session[:is_check_all] = false
    flash[:notice] = message
    redirect_to dashboards_admin_permohonan_path
  end

  def submission_delete
    submissions = Submission.where(id: submission_ses)
    submissions.destroy_all

    session[:submission_ids] = []
    session[:is_check_all] = false
    flash[:notice] = 'Berhasil menghapus permohonan.'
    redirect_to dashboards_admin_permohonan_path
  end

  def index
    @role = current_user.role_name.downcase
    @search = Submission.submission_todays(@role).ransack(params[:q])
    @submission_recaps = Submission.all.group(:submission_status).group_by_month(:submission_date).count
    @submission_todays = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])
    session[:return_back] = request.fullpath

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"permohonan-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"permohonan-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :index }
    end
  end

  def accept_submission
    @admin_referrals = Submission.admin_referrals
  end

  def process_accept_submission
    if current_user.admin_buku_tanah?
      @message = 'BERKAS TERKIRIM KE KASUBSI PENDAFTARAN'
      notif_type = 'Selesai di Admin Buku Tanah'
      @submission.nib = params['nib']
      @submission.land_book_status = 'selesai'
    end

    if current_user.admin_validasi?
      notif_type = 'Selesai di Admin Validasi'
      @message = 'BERKAS TERKIRIM KE KASUBSI TEMATIK'
      @submission.submission_status = 'selesai'
    end

    if current_user.admin_pola_ruang?
      @submission.nib = params['nib']
      notif_type = 'Selesai di Admin Pola Ruang'
      @submission.space_pattern_status = 'selesai'
      @message = 'BERKAS TERKIRIM KE KASUBSI POLA RUANG'
      @submission.admin_referral = params['admin_referral']
    end

    send_notification(@submission, notif_type, 'selesai', params['notes'])
    set_note(@submission, params['notes'])

    @submission.save

    redirect_to admin_accept_submission_path(
      @submission,
      success: true,
      message: @message,
      links: session[:return_back],
      code: @submission.submission_code
    )
  end

  def detail_submission; end

  def delete_submission
    submissions = Submission.where(id: params['id'])
    submissions.destroy_all

    flash[:notice] = 'Permohonan berhasil dihapus.'
    redirect_to session[:return_back]
  end

  def applications
    @search = Submission.admin_applications(@role).ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])

    set_export_data if params[:export]

    session[:return_back] = request.fullpath
    session[:all_submission_ids] = @search.result.pluck(:id).map(&:to_s)

    p '============'
    p session[:all_submission_ids]
    p '============'

    if params[:archive]
      shp_file_name = "permohonan(#{Time.now.strftime('%d%m%Y-%H%M%S')})"
      ShpBuilder.generate_csv_shp(@exports, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"semua-permohonan-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"semua-permohonan-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :applications }
    end
  end

  def revisions
    @search = Submission.admin_revisions(@role).ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])

    set_export_data if params[:export]

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"revisi-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"revisi-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :revisions }
    end
  end

  def counter
    @search = Submission.admin_counters(@role).ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page(params[:page]).per(params[:per])

    set_export_data if params[:export]

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"selesai-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"selesai-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :counter }
    end
  end

  def process_member_revision
    @submission.update(submission_status: 'revisi')     if current_user.admin_validasi?
    @submission.update(land_book_status: 'revisi')      if current_user.admin_buku_tanah?
    @submission.update(space_pattern_status: 'revisi')  if current_user.admin_pola_ruang?
    notif_type = member_revision_type
    send_notification(@submission, notif_type, 'revisi', params['notes'])

    @message = "BERKAS #{@submission.submission_code} TERKIRIM KE MEMBER UNTUK DIREVISI"

    redirect_to admin_member_revision_path(
      @submission,
      success: true,
      message: @message,
      links: session[:return_back]
    )
  end

  def member_revisions; end

  def taken_submission; end

  def process_taken_submission
    note_type ||= 'Admin Buku Tanah'  if current_user.admin_buku_tanah?
    note_type ||= 'Admin Validasi'    if current_user.admin_validasi?
    note_type ||= 'Admin Pola Ruang'  if current_user.admin_pola_ruang?
    note_type ||= nil

    @submission.notes.create(note_type: note_type, name: 'Ambil', description: params['notes'])
    @submission.pick_up_date = Time.now
    @submission.save
    flash[:notice] = 'Permohonan berhasil diambil.'
    redirect_to dashboards_admin_permohonan_loket_path
  end

  private

  def set_export_data
    results = @search.result
    @exports ||= results.limit(@per) if @per
    @exports ||= results.where(id: submission_ses).except(:limit, :offset) unless submission_ses.empty?
    @exports ||= results.includes(:sub_district, :village, :hak_type).except(:limit, :offset) if @search_cont || @gteq_params || @lteq_params
    @exports ||= @submissions

    @exports
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

  def set_note(submission, note)
    note_type ||= 'Admin Buku Tanah'  if current_user.admin_buku_tanah?
    note_type ||= 'Admin Validasi'    if current_user.admin_validasi?
    note_type ||= 'Admin Pola Ruang'  if current_user.admin_pola_ruang?
    note_type ||= nil

    submission.notes.create(note_type: note_type, name: 'Admin Selesai', description: note)
  end

  def member_revision_type
    type ||= 'Revisi Surat Ukur' if current_user.admin_validasi?
    type ||= 'Revisi Pola Ruang' if current_user.admin_pola_ruang?
    type ||= 'Revisi Buku Tanah' if current_user.admin_buku_tanah?
    type
  end

  def set_ransact_value
    @doc_gteq_params = begin
                      params['q']['date_of_completion_gteq']
                    rescue StandardError
                      ''
                    end
    @doc_lteq_params = begin
                    params['q']['date_of_completion_lteq']
                  rescue StandardError
                    ''
                  end
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
    @per = begin
            params['per']
          rescue StandardError
            ''
          end
    @search_cont = begin
                    params['q']['fullname_or_submission_code_cont']
                  rescue StandardError
                    ''
                  end
  end

  def set_submission
    @submission = Submission.find_by(id: params[:id])
    return redirect_to dashboards_admin_path if @submission.nil?
  end
end
