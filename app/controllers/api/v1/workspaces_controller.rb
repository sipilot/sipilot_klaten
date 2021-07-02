class Api::V1::WorkspacesController < Api::BaseController
  def index
    @search = current_user_api.workspaces.ransack(params[:search])
    workspaces = @search.result

    return api_success_response([]) if workspaces.nil?

    results = workspaces.map do |workspace|
      {
        id: workspace.id,
        rt: workspace.rt,
        rw: workspace.rw,
        village_id: workspace.village_id,
        district_id: workspace.district_id,
        sub_district_id: workspace.sub_district_id,
        name: workspace.name,
        village: workspace.village_name,
        district: workspace.district_name,
        sub_district: workspace.sub_district_name,
        total_records: workspace.gps_plottings.count
      }
    end
    api_success_response(results)
  end

  def create
    my_total_workspace = current_user_api.workspaces.count
    return api_error_response(['Cannot create workspace. Maks 5 workspace']) if my_total_workspace >= 5

    workspace = current_user_api.workspaces.new(create_workspace_params)
    if workspace.save
      api_success_response({ message: 'success create workspace' })
    else
      api_error_response(workspace.errors.full_messages)
    end
  end

  def process_import_submission
    workspace = current_user_api.workspaces.find_by(id: params[:workspace_id])
    return api_error_response(['Invalid file or workspace.']) unless workspace && params[:file]

    import = {
      file: params[:file],
      user: current_user_api,
      workspace: workspace
    }

    gps_import = GpsPlottingImport.new(import)
    if gps_import.save
      api_success_response({ message: 'Success import.' })

      return
    end

    api_error_response(gps_import.errors.full_messages)
  end

  def format_import_submission
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"format-import-gps.xlsx\""
      }
    end
  end

  def list_submissions
    search = current_user_api.gps_with_workspace(params['workspace_id']).order('created_at desc').ransack(params[:search])
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
        dikirim_pada: gps.sent,
        bertindak_atas: gps.act_for,
        nama_pendaftar: gps.on_behalf,
        alamat_tanah: gps.land_address,
        kecamatan: gps.sub_district_name,
        nama_pemilik_sertipikat: gps.fullname,
        status_sertipikat: gps.certificate_status,
        workspace_id: gps.workspace.try(:id),
        workspace_name: gps.workspace.try(:name),
        files: gps.submission_files.map do |sf|
          {
            id: sf.id,
            file_type: sf.file_type,
            description: sf.description,
            image: (url_for(sf.image) rescue '')
          }
        end
      }
    end
    api_success_response(response)
  end

  def detail_submission
    gps_plotting = current_user_api.gps_plottings.find_by(id: params[:id])
    return api_error_response(['Data not found.']) unless gps_plotting

    results = {
      id: gps_plotting.id,
      status: gps_plotting.status,
      dikirim_pada: gps_plotting.sent,
      desa: gps_plotting.village_name,
      jenis_hak: gps_plotting.hak_name,
      lattitude: gps_plotting.lattitude,
      longitude: gps_plotting.longitude,
      nomor_hak: gps_plotting.hak_number,
      bertindak_atas: gps_plotting.act_for,
      nama_pendaftar: gps_plotting.on_behalf,
      alamat_tanah: gps_plotting.land_address,
      nama_pemilik_sertipikat: gps_plotting.fullname,
      files: gps_plotting.submission_files.map do |sf|
        {
          id: sf.id,
          file_type: sf.file_type,
          description: sf.description,
          image: (url_for(sf.image) rescue '')
        }
      end
    }

    api_success_response(results)
  end

  def delete_submissions
    submissions = current_user_api.gps_plottings.where(id: params['ids'])
    return api_error_response(['Not founds.']) unless submissions.any?

    submissions.destroy_all
    api_success_response({ message: 'Success delete.' })
  end

  def sent_submissions
    submissions = current_user_api.gps_plottings.where(id: params['ids'])
    return api_error_response(['Not founds.']) unless submissions.any?

    submissions.update_all(sent_at: Time.now)
    api_success_response({ message: 'Success sent.' })
  end

  def create_submission
    gps_plotting = current_user_api.gps_plottings.new(params_gps_plotting)
    gps_plotting.village_id       = params['village_id'].to_i
    gps_plotting.hak_type_id      = params['hak_type_id'].to_i
    gps_plotting.alas_type_id     = params['alas_type_id'].to_i
    gps_plotting.sub_district_id  = params['sub_district_id'].to_i
    if gps_plotting.save
      gps_plotting.submission_files.create(image: params['id_number'], file_type: 'id_number')
      gps_plotting.submission_files.create(image: params['land_book'], file_type: 'land_book')
      gps_plotting.submission_files.create(image: params['measuring_letter'], file_type: 'measuring_letter')
      gps_plotting.submission_files.create(image: params['authority_letter'], file_type: 'authority_letter')
      gps_plotting.submission_files.create(image: params['location_description'], file_type: 'location_description')
      gps_plotting.submission_files.create(image: params['proof_of_alas'], file_type: 'proof_of_alas')
      api_success_response({ message: 'Success submit.' })
    else
      api_error_response(gps_plotting.errors.full_messages)
    end
  end

  def update_submissions
    gps_plotting = current_user_api.gps_plottings.find_by(id: params['submission_id'])
    if gps_plotting
      gps_plotting.update(
        village_id: params['village_id'].to_i,
        hak_type_id: params['hak_type_id'].to_i,
        sub_district_id: params['sub_district_id'].to_i
      )
      gps_plotting.update(update_gps_params)
      gps_plotting.api_process_submission_image_update(
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

  def villages
    villages = Village.select('id, name').where('id IN(select village_id from workspaces where user_id = ?)', current_user_api.id).order('name asc')
    api_success_response(villages)
  end

  private

  def create_workspace_params
    params.permit(
      :rt,
      :rw,
      :name,
      :date_to,
      :date_from,
      :village_id,
      :district_id,
      :sub_district_id
    )
  end

  def params_gps_plotting
    params.permit(
      :act_for,
      :hay_type,
      :fullname,
      :lattitude,
      :on_behalf,
      :longitude,
      :hak_number,
      :workspace_id,
      :land_address,
      :certificate_status
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
      :workspace_id,
      :certificate_status
    )
  end
end
