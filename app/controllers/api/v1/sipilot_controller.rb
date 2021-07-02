class Api::V1::SipilotController < Api::BaseController
  def services
    services = Service.select('id, name, description')
    api_success_response(services)
  end

  def index
    validations   = current_user_api.submissions.list_validation
    space_pattern = current_user_api.submissions.list_space_pattern
    data = [
      {
        type: 'validations',
        total: validations.count
      },
      {
        type: 'space pattern',
        total: space_pattern.count
      }
    ]
    api_success_response(data)
  end

  def recaps
    end_results = []
    months.each do |month|
      submissions = current_user_api.submissions.includes(:service).select { |submission| submission.created_at.strftime('%B').downcase == month[:name].downcase }
      if submissions.nil?
        end_results << month
        next
      end

      submissions.each do |submission|
        if submission.service_name.downcase == 'validasi'
          if submission.submission_status == 'revisi' ||
             submission.land_book_status == 'revisi'

            month[:revisions] += 1

            next
          end

          if submission.submission_status == 'proses' ||
             submission.land_book_status == 'proses' ||
             submission.kasubsi_tematik_status == 'proses' ||
             submission.kasubsi_registration_status == 'proses'

            month[:in_progress] += 1

            next
          end

          month[:done] += 1
        end

        next if submission.service_name.downcase != 'pola ruang'

        if submission.space_pattern_status == 'revisi'
          month[:revisions] += 1

          next
        end

        if submission.space_pattern_status == 'proses' ||
           submission.kasubsi_space_pattern_status == 'proses'

          month[:in_progress] += 1

          next
        end

        month[:done] += 1
      end

      end_results << month
    end
    api_success_response(end_results)
  end

  def submissions_recaps
    results = [
      {
        done: 0, process: 0, revisions: 0, service_id: 0, total: 0, type: 'space pattern'
      },
      {
        done: 0, process: 0, revisions: 0, service_id: 0, total: 0, type: 'validations'
      }
    ]
    submissions = current_user_api.submissions.includes(:service)
    submissions.each do |submission|
      if submission.service_name.downcase == 'validasi'
        results.last[:total] += 1

        if submission.submission_status == 'revisi' ||
           submission.land_book_status == 'revisi'
          results.last[:revisions] += 1

          next
        end

        if submission.submission_status == 'proses' ||
           submission.land_book_status == 'proses' ||
           submission.kasubsi_tematik_status == 'proses' ||
           submission.kasubsi_registration_status == 'proses'

          results.last[:process] += 1

          next
        end

        results.last[:done] += 1
      end

      next if submission.service_name.downcase != 'pola ruang'

      results.first[:total] += 1

      if submission.space_pattern_status == 'revisi'
        results.first[:revisions] += 1

        next
      end

      if submission.space_pattern_status == 'proses' ||
         submission.kasubsi_space_pattern_status == 'proses'

        results.first[:process] += 1

        next
      end

      results.first[:done] += 1
    end

    api_success_response(results)
  end

  def submissions_all
    search = current_user_api.submissions.where(service_id: params['service_id']).order('created_at desc').ransack(params[:search])
    submissions = search.result.page(params['page']).per(params['per'])
    results = submissions.map do |submission|
      payload_submission_list(submission)
    end
    api_success_response(results)
  end

  def submission_delete
    submissions = current_user_api.submissions.where(id: params['submission_ids'])
    submissions.destroy_all
    api_success_response({ message: 'Success delete.' })
  end

  def submissions_create
    if @is_closed
      api_error_response([Setting.closed_office_message])
      return
    end

    sbs = current_user_api.submissions.new(submission_params)
    sbs.service_id      = params['service_id']
    sbs.hak_type_id     = params['hak_type_id']
    sbs.village_id      = params['village_id'].to_i
    sbs.sub_district_id = params['sub_district_id'].to_i
    if sbs.save
      sbs.process_submission_image_nested(params['land_book'], params['measuring_letter'], params['id_number'], params['authority_letter'])
      api_success_response({ message: 'Success submit.' })
    else
      api_error_response(sbs.errors.full_messages)
    end
  end

  def submissions_update
    if @is_closed
      api_error_response([Setting.closed_office_message])
      return
    end

    submission    = current_user_api.submissions.find_by(id: params['submission_id'])
    notification  = Notification.find_by(id: params['notification_id'])
    if notification.present? && submission.present?
      submission.update(update_submission_params)
      submission.update(
        hak_type_id: params['hak_type_id'],
        village_id: params['village_id'].to_i,
        sub_district_id: params['sub_district_id'].to_i
      )

      submission.update(land_address: params['land_address'])    unless params['land_address'].empty?
      submission.update(land_book_status: 'sudah direvisi')      if notification.title.include? 'Revisi Buku Tanah'
      submission.update(submission_status: 'sudah direvisi')     if notification.title.include? 'Revisi Surat Ukur'
      submission.update(space_pattern_status: 'sudah direvisi')  if notification.title.include? 'Revisi Pola Ruang'

      notification.update(read_at: Time.now)
      submission.process_submission_image_update(params['land_book'], params['measuring_letter'], params['id_number'], params['authority_letter'])
      api_success_response({ message: 'Success update.' })
    else
      api_error_response(['Submission not found.'])
    end
  end

  def all_completed_submission
    search = {}
    search[:date_of_completion_gteq] = params['search']['created_at_gteq']
    search[:date_of_completion_lteq] = params['search']['created_at_lteq']
    @search = current_user_api.submissions.where(
      '(submission_status = ? AND kasubsi_tematik_status = ? AND land_book_status = ? AND kasubsi_registration_status = ?) OR
      (space_pattern_status = ? AND kasubsi_space_pattern_status = ?)',
      'selesai', 'selesai', 'selesai', 'selesai', 'selesai', 'selesai').order('created_at desc').ransack(search)
    results = @search.result.page(params['page']).per(params['per'])
    response = results.map do |submission|
      payload_submission_list(submission)
    end
    api_success_response(response)
  end

  def delete_completed_submission
    submissions = current_user_api.submissions.where(id: params['submission_ids'])
    return api_error_response(['Berkas not found']) if submissions.empty?

    submissions.destroy_all
    api_success_response({ message: 'Success delete.' })
  end

  def submissions_detail
    submission = current_user_api.submissions.find_by(id: params[:id])
    return api_error_response(['Submission not found']) if submission.nil?

    result = payload_submission_detail(submission)
    api_success_response(result)
  end

  def download_completed_submission
    return api_error_response(['Invalid parameter']) if params['ids'].nil?

    @submissions_exports = current_user_api.submissions.where(id: params['ids']).order('created_at desc')
    @service_name = @submissions_exports.first.service_name
    respond_to do |format|
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"berkas_selesai-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"berkas_selesai-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
    end
  end

  def submissions_download
    return api_error_response(['Invalid parameter']) if params['ids'].nil?

    @submissions_exports = current_user_api.submissions.where(id: params['ids']).order('created_at desc')

    @service_name ||= @submissions_exports.first.service_name.upcase rescue '' if @submissions_exports
    @service_name ||= ''

    respond_to do |format|
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"permohonan-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
    end
  end

  def detail_completed_submission
    submission = current_user_api.submissions.find_by(id: params[:id])
    return api_error_response(['Berkas not found']) if submission.nil?

    result = payload_submission_detail(submission)
    api_success_response(result)
  end

  private

  def update_submission_params
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

  def payload_submission_detail(submission)
    {
      id: submission.id,
      catatan: submission.notes,
      desa: submission.village_name,
      kecamatan: submission.sub_district_name,
      jenis_hak: submission.hak_name,
      lattitude: submission.lattitude,
      longitude: submission.longitude,
      tgl_permohonan: submission.date,
      nomor_hak: submission.hak_number,
      kode: submission.submission_code,
      service: submission.service_name,
      bertindak_atas: submission.act_for,
      status: submission.submission_status,
      nama_pendaftar: submission.on_behalf,
      alamat_tanah: submission.land_address,
      tanggal_selesai: submission.date_completion,
      nama_pemilik_sertipikat: submission.fullname,
      status_buku_tanah: submission.land_book_status,
      status_surat_ukur: submission.submission_status,
      nomor_pendaftaran: submission.registration_code,
      status_pola_ruang: submission.space_pattern_status,
      status_kasubsi_tematik: submission.kasubsi_tematik_status,
      status_kasubsi_pola_ruang: submission.kasubsi_space_pattern_status,
      status_kasubsi_pendaftaran: submission.kasubsi_registration_status,
      files: submission.submission_files.map do |sf|
        {
          id: sf.id,
          file_type: sf.file_type,
          description: sf.description,
          image: (url_for(sf.image) rescue '')
        }
      end
    }
  end

  def payload_submission_list(submission)
    {
      id: submission.id,
      catatan: submission.notes,
      desa: submission.village_name,
      jenis_hak: submission.hak_name,
      lattitude: submission.lattitude,
      longitude: submission.longitude,
      nomor_hak: submission.hak_number,
      kode: submission.submission_code,
      service: submission.service_name,
      bertindak_atas: submission.act_for,
      status: submission.submission_status,
      nama_pendaftar: submission.on_behalf,
      alamat_tanah: submission.land_address,
      kecamatan: submission.sub_district_name,
      tanggal_selesai: submission.date_completion,
      nama_pemilik_sertipikat: submission.fullname,
      status_buku_tanah: submission.land_book_status,
      status_surat_ukur: submission.submission_status,
      nomor_pendaftaran: submission.registration_code,
      status_pola_ruang: submission.space_pattern_status,
      status_kasubsi_tematik: submission.kasubsi_tematik_status,
      status_kasubsi_pola_ruang: submission.kasubsi_space_pattern_status,
      status_kasubsi_pendaftaran: submission.kasubsi_registration_status
    }
  end

  def submission_params
    params.permit(
      :act_for,
      :hay_type_id,
      :fullname,
      :lattitude,
      :longitude,
      :on_behalf,
      :hak_number,
      :land_address
    )
  end

  def months
    [
      { name: 'january', in_progress: 0, revisions: 0, done: 0 },
      { name: 'february', in_progress: 0, revisions: 0, done: 0 },
      { name: 'march', in_progress: 0, revisions: 0, done: 0 },
      { name: 'april', in_progress: 0, revisions: 0, done: 0 },
      { name: 'may', in_progress: 0, revisions: 0, done: 0 },
      { name: 'june', in_progress: 0, revisions: 0, done: 0 },
      { name: 'july', in_progress: 0, revisions: 0, done: 0 },
      { name: 'august', in_progress: 0, revisions: 0, done: 0 },
      { name: 'september', in_progress: 0, revisions: 0, done: 0 },
      { name: 'october', in_progress: 0, revisions: 0, done: 0 },
      { name: 'november', in_progress: 0, revisions: 0, done: 0 },
      { name: 'december', in_progress: 0, revisions: 0,done: 0 }
    ]
  end
end
