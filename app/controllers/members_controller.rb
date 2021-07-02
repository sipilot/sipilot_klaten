class MembersController < ApplicationController
  layout 'dashboards'

  before_action :authenticate_user!
  before_action :set_notifications
  before_action :set_form_data, only: [
    :space_pattern_submission,
    :validation_submission,
    :submission_edit
  ]
  before_action :set_ransact_value, only: %i[validation space_pattern]
  before_action :find_submission, only: %i[
    submission_edit
    submission_detail
    prosess_submission_edit
  ]
  before_action :set_pagination_state, only: %i[
    validation
    space_pattern
  ]

  def index
    read_notification
    @land_value_zone = 0
    @submission_recaps = current_user.submissions
    @total_validation_services = current_user.submissions.total_validation
    @total_space_pattern_service = current_user.submissions.total_space_pattern
  end

  def profile
    @user = current_user
  end

  def validation
    @search = current_user.submissions.list_validation.ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page params[:page]

    respond_to do |format|
      format.xlsx {
        @submissions_exports = current_user.submissions.list_validation.except(:limit, :offset)
        response.headers['Content-Disposition'] = "attachment; filename=\"pendaftaran_validasi-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        @submissions_exports = current_user.submissions.list_validation.except(:limit, :offset)
        headers['Content-Disposition'] = "attachment; filename=\"pendaftaran_validasi-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :validation }
    end
  end

  def space_pattern
    @search = current_user.submissions.list_space_pattern.ransack(params[:q])
    @submissions = @search.result.includes(:sub_district, :village, :hak_type).page params[:page]

    respond_to do |format|
      format.xlsx {
        @submissions_exports = current_user.submissions.list_space_pattern.except(:limit, :offset)
        response.headers['Content-Disposition'] = "attachment; filename=\"pendaftaran_pola_ruang-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        @submissions_exports = current_user.submissions.list_space_pattern.except(:limit, :offset)
        headers['Content-Disposition'] = "attachment; filename=\"pendaftaran_pola_ruang-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :space_pattern }
    end
  end

  def submission_detail; end

  def submission_edit
    submission_files = @submission.submission_files.group_by {|v| v.file_type}
    @images = submission_files.map do |image|
      {
        name: image[0],
        images: image[-1]
      }
    end
  end

  def prosess_submission_edit
    notification = Notification.find_by(id: params['notification'])
    if notification.present?
      @submission.update(edit_submission_params)
      @submission.update(
        hak_type_id: params['hak_type'],
        village_id: params['village'].to_i,
        sub_district_id: params['sub_district'].to_i
      )

      @submission.update(land_address: params['land_address'])    unless params['land_address'].empty?
      @submission.update(land_book_status: 'sudah direvisi')      if notification.title.include? 'Revisi Buku Tanah'
      @submission.update(submission_status: 'sudah direvisi')     if notification.title.include? 'Revisi Surat Ukur'
      @submission.update(space_pattern_status: 'sudah direvisi')  if notification.title.include? 'Revisi Pola Ruang'

      notification.update(read_at: Time.now)
      @submission.process_submission_image_update(params['land_book'], params['measuring_letter'], params['id_number'], params['authority_letter'])
      flash[:notice] = 'Berhasil melakukkan revisi.'
    end

    redirect_to dashboards_member_validasi_path
  end

  def space_pattern_submission
    @hak_types = HakType.ordered
    session[:return_back] = request.fullpath
  end

  def validation_submission
    @hak_types = HakType.without_certificate_status
    session[:return_back] = request.fullpath
  end

  def validation_process_submission
    sbs = current_user.submissions.new(submission_params)
    sbs.hak_type_id     = params['hak_type']
    sbs.service_id      = Service.validation_id
    sbs.village_id      = params['village'].to_i
    sbs.sub_district_id = params['sub_district'].to_i

    if sbs.save
      sbs.process_submission_image_nested(params['land_book'], params['measuring_letter'], params['id_number'], params['authority_letter'])
      flash[:notice] = 'Berhasil melakukkan pendaftaran.'
      redirect_to dashboards_member_validasi_path
    else
      flash[:errors] = sbs.errors.full_messages
      redirect_to session[:return_back]
    end
  end

  def space_pattern_process_submission
    sbs = current_user.submissions.new(submission_params)
    sbs.hak_type_id     = params['hak_type']
    sbs.village_id      = params['village'].to_i
    sbs.service_id      = Service.space_pattern_id
    sbs.sub_district_id = params['sub_district'].to_i

    if sbs.save
      sbs.process_submission_image_nested(params['land_book'], params['measuring_letter'], params['id_number'], params['authority_letter'])
      flash[:notice] = 'Berhasil melakukkan pendaftaran.'
      redirect_to dashboards_member_pola_ruang_path
    else
      flash[:errors] = sbs.errors.full_messages
      redirect_to session[:return_back]
    end
  end

  private

  def read_notification
    return unless params['notification_id']

    Notification.find_by(id: params['notification_id']).update(read_at: Time.now)
  end

  def find_submission
    @submission = Submission.find_by(id: params[:id])
    return redirect_to dashboards_member_path if @submission.nil?
  end

  def set_ransact_value
    @gteq_params = params['q']['created_at_gteq'] rescue ''
    @lteq_params = params['q']['created_at_lteq'] rescue ''
  end

  # NOTE : need optimize
  def set_notifications
    @notifications = current_user.my_notifications
  end

  def set_form_data
    @villages       = Village.ordered
    @act_fors       = Submission.act_fors
    @sub_districts  = SubDistrict.ordered
  end

  def submission_params
    params.permit(
      :act_for,
      :fullname,
      :hay_type,
      :longitude,
      :lattitude,
      :on_behalf,
      :hak_number,
      :land_address
    )
  end

  def edit_submission_params
    params.permit(
      :act_for,
      :hay_type,
      :fullname,
      :lattitude,
      :on_behalf,
      :longitude,
      :hak_number
    )
  end
end
