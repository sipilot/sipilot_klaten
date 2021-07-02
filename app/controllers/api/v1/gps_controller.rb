class Api::V1::GpsController < Api::BaseController
  def index
    gps_plottings = current_user_api.gps_plottings
    response = {
      total_entries: gps_plottings.count,
      total_village: gps_plottings.select(:village_id).distinct.count(:village_id),
      total_sub_district: gps_plottings.select(:sub_district_id).distinct.count(:sub_district_id)
    }
    api_success_response(response)
  end

  def detail_recapitulation
    gps_plottings = current_user_api.gps_plottings.group_by {|v| [v.sub_district, v.village]}
    response = gps_plottings.map do |gps|
      {
        total: gps.last.count,
        village: gps.first[-1].name,
        sub_district: gps.first[0].name
      }
    end
    api_success_response(response)
  end

  def concurrent_requests
    search = current_user_api.gps_plottings.ransack(params[:search])
    gps_plottings = search.result.includes(:sub_district, :village)
    grouped_data = gps_plottings.group_by {|v| [v.sub_district, v.village]}
    response = grouped_data.map do |gps|
      {
        total: gps.last.count,
        village: gps.first[-1].name,
        sub_district: gps.first[0].name
      }
    end
    limit = (params[:per].to_i - 1) rescue 0
    eliminated = response[0..limit]
    api_success_response(eliminated)
  end

  def download_concurrent_requests
    return api_error_response(['Invalid parameter']) if params['ids'].nil?

    @submissions_exports = current_user_api.gps_plottings.where(id: params['ids']).order('created_at desc')
    if params[:archive]
      shp_file_name = "permohonan_gps(#{Time.now.strftime('%d%m%Y-%H%M')})"
      ShpBuilder.generate_csv_shp(@submissions_exports, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"permohonan_gps-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"permohonan_gps-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
    end
  end

  def send_concurrent_requests
    gps_plottings = current_user_api.gps_plottings.where(id: params[:ids])
    return api_error_response(['Not founds.']) if gps_plottings.empty?

    gps_plottings.update_all(sent_at: Time.now, status: 3)
    api_success_response({ message: 'Success sent.' })
  end

  def delete_concurrent_requests
    gps_plottings = current_user_api.gps_plottings.where(id: params[:ids])
    return api_error_response(['Not founds.']) if gps_plottings.empty?

    gps_plottings.destroy_all
    api_success_response({ message: 'Success delete.' })
  end

  def list_concurrent_requests
    search = current_user_api.gps_with_workspace(params['workspace_id']).ransack(params[:search])
    gps_plottings = search.result.page(params['page']).per(params['per'])
    response = gps_plottings.map do |gps|
      {
        id: gps.id,
        desa: gps.village_name,
        jenis_hak: gps.hak_name,
        jenis_alas: gps.alas_name,
        lattitude: gps.lattitude,
        longitude: gps.longitude,
        nomor_hak: gps.hak_number,
        bertindak_atas: gps.act_for,
        nama_pendaftar: gps.on_behalf,
        alamat_tanah: gps.land_address,
        kecamatan: gps.sub_district_name,
        status_sertipikat: gps.certificate_status,
        nama_pemilik_sertipikat: gps.fullname,
        workspace_id: gps.workspace.try(:id),
        workspace_name: gps.workspace.try(:name)
      }
    end
    api_success_response(response)
  end

  def insert_concurrent_requests
    gps_plotting = current_user_api.gps_plottings.new(params_gps_plotting)
    gps_plotting.village_id       = params['village_id'].to_i
    gps_plotting.hak_type_id      = params['hak_type_id'].to_i
    gps_plotting.sub_district_id  = params['sub_district_id'].to_i
    if gps_plotting.save
      gps_plotting.process_submission_image_nested(
        params['land_book'],
        params['measuring_letter'],
        params['id_number'],
        params['authority_letter'],
        params['proof_of_alas'],
        params['location_description']
      )
      api_success_response({ message: 'Success submit.' })
    else
      api_error_response(gps_plotting.errors.full_messages)
    end
  end

  def update_concurrent_requests
    gps_plotting = current_user_api.gps_plottings.find_by(id: params['submission_id'])
    if gps_plotting
      gps_plotting.update(
        village_id: params['village_id'].to_i,
        hak_type_id: params['hak_type_id'].to_i,
        sub_district_id: params['sub_district_id'].to_i
      )
      gps_plottings.update(update_gps_params)
      gps_plotting.process_submission_image_update(
        params['land_book'],
        params['measuring_letter'],
        params['id_number'],
        params['authority_letter'],
        params['proof_of_alas'],
        params['location_description']
      )
      api_success_response({ message: 'Success update.' })
    else
      api_error_response(['Not founds.'])
    end
  end

  def detail_concurrent_requests
    submission = current_user_api.gps_plottings.find_by(id: params[:id])
    return api_error_response(['Berkas not found']) if submission.nil?

    result = payload_submission_detail(submission)
    api_success_response(result)
  end

  def all_completed_submission
    @search   = current_user_api.gps_plottings.where('sent_at IS NOT NULL').order('created_at desc').ransack(params[:search])
    results   = @search.result.page(params['page']).per(params['per'])
    response  = results.map do |submission|
      payload_submission_list(submission)
    end
    api_success_response(response)
  end

  def delete_completed_submission
    submissions = current_user_api.gps_plottings.where(id: params['submission_ids'])
    return api_error_response(['Not founds.']) unless submissions.any?

    submissions.destroy_all
    api_success_response({ message: 'Success delete.' })
  end

  def detail_completed_submission
    submission = current_user_api.gps_plottings.find_by(id: params[:id])
    return api_error_response(['Berkas not found']) if submission.nil?

    result = payload_submission_detail(submission)
    api_success_response(result)
  end

  def download_completed_submission
    return api_error_response(['Invalid parameter']) if params['ids'].nil?

    @submissions_exports = current_user_api.gps_plottings.where(id: params['ids']).order('created_at desc')
    if params[:archive]
      shp_file_name = "berkas_selesai(#{Time.now.strftime('%d%m%Y-%H%M')})"
      ShpBuilder.generate_csv_shp(@submissions_exports, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"berkas_selesai-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"berkas_selesai-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
    end
  end

  private

  def payload_submission_list(submission)
    {
      id: submission.id,
      status: submission.status,
      jenis_hak: submission.hak_name,
      desa: submission.village_name,
      lattitude: submission.lattitude,
      longitude: submission.longitude,
      nomor_hak: submission.hak_number,
      bertindak_atas: submission.act_for,
      nama_pendaftar: submission.on_behalf,
      alamat_tanah: submission.land_address,
      nama_pemilik_sertipikat: submission.fullname
    }
  end

  def payload_submission_detail(submission)
    {
      id: submission.id,
      status: submission.status,
      dikirim_pada: submission.sent,
      desa: submission.village_name,
      jenis_hak: submission.hak_name,
      lattitude: submission.lattitude,
      longitude: submission.longitude,
      nomor_hak: submission.hak_number,
      bertindak_atas: submission.act_for,
      nama_pendaftar: submission.on_behalf,
      alamat_tanah: submission.land_address,
      nama_pemilik_sertipikat: submission.fullname,
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

  def params_gps_plotting
    params.permit(
      :act_for,
      :hay_type,
      :alas_type_id,
      :fullname,
      :lattitude,
      :on_behalf,
      :longitude,
      :hak_number,
      :land_address,
      :workspace_id
    )
  end

  def update_gps_params
    params.permit(
      :act_for,
      :hay_type,
      :alas_type_id,
      :fullname,
      :lattitude,
      :on_behalf,
      :longitude,
      :hak_number,
      :land_address,
      :workspace_id
    )
  end
end
