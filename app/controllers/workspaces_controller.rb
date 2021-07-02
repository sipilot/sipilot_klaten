class WorkspacesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workspace, only: %i[show delete detail]

  layout 'dashboards'

  def index
    @last_query = params['q']['name_cont'] rescue ''
    @search = current_user.workspaces.ransack(params[:q])
    @results = @search.result.page(params['page']).per(params['per'])
    session[:return_back] = request.fullpath
  end

  def create
    @villages = Village.ordered
    @districts = District.ordered
    @sub_districts = SubDistrict.ordered
  end

  def process_create
    workspace = current_user.workspaces.new(create_workspace_params.except(:village, :district, :sub_district))
    workspace.district_id = params['district'].to_i
    workspace.village_id  = params['village'].to_i
    workspace.sub_district_id = params['sub_district'].to_i
    total_workspaces = current_user.workspaces.count

    if total_workspaces >= 5
      flash[:errors] = ['Jumlah workspace sudah mencapai maksimal.']
      redirect_to gps_workspaces_create_path

      return
    end

    if workspace.save
      flash[:notice] = 'Berhasil menambah workspace.'
      redirect_to session[:return_back]
    else
      flash[:errors] = workspace.errors.full_messages
      redirect_to gps_workspaces_create_path
    end
  end

  def detail; end

  def show
    @search = @workspace.gps_plottings.where('sent_at IS NULL').ransack(params[:q])
    @results = @search.result.page(params['page']).per(params['per'])
    session[:return_back] = request.fullpath
  end

  def process_data
    action_type = params['button'].downcase
    gps_plottings = current_user.gps_plottings.where(id: params['submission_ids'])
    if action_type == 'kirim'
      notice = "Berhasil mengirim #{gps_plottings.count} data."
      gps_plottings.update_all(sent_at: Time.now)
    end

    if action_type == 'hapus'
      notice = "Berhasil menghapus #{gps_plottings.count} data."
      gps_plottings.destroy_all
    end

    flash[:notice] = notice
    redirect_to session[:return_back]
  end

  def delete
    @workspace.destroy
    redirect_to gps_workspaces_path
  end

  def detail_submission
    @submission = current_user.gps_plottings.find_by(id: params['submission_id'])
  end

  def import_submission
    @workspace = Workspace.find_by(id: params['id'])
  end

  def format_import_submission
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"format-import-gps.xlsx\""
      }
    end
  end

  def process_import_submission
    workspace = Workspace.find_by(id: params['id'])
    import = {
      file: params[:file],
      user: current_user,
      workspace: workspace
    }

    gps_import = GpsPlottingImport.new(import)
    if gps_import.save
      flash[:notice] = 'Berhasil import data.'
      redirect_to session[:return_back]

      return
    end

    flash[:errors] = gps_import.errors.full_messages
    redirect_to gps_member_workspaces_import_submission_path
  end

  def new_submission
    @workspace = current_user.workspaces.find_by(id: params['id'])
    @villages       = Village.ordered
    @hak_types      = HakType.without_certificate_status.ordered
    @alas_types     = AlasType.ordered
    @act_fors       = GpsPlotting.act_fors
    @sub_districts  = SubDistrict.ordered
    @certificate_statuses = GpsPlotting.certificate_statuses
    session[:return_back] = request.fullpath
  end

  def process_new_submission
    workspace = current_user.workspaces.find_by(id: params['id'])
    gps = current_user.gps_plottings.new(gps_plotting_params)
    gps.workspace_id    = workspace.id
    gps.hak_type_id     = params['hak_type']
    gps.alas_type_id    = params['alas_type']
    gps.village_id      = params['village'].to_i
    gps.sub_district_id = params['sub_district'].to_i
    if gps.save
      gps.process_submission_image_nested(
        params['land_book'],
        params['measuring_letter'],
        params['id_number'],
        params['authority_letter'],
        params['proof_of_alas'],
        params['location_description']
      )
      redirect_to gps_member_workspaces_show_path(workspace.id)
    else
      flash[:errors] = gps.errors.full_messages
      redirect_to session[:return_back]
    end
  end

  def update_submission
    @submission = current_user.gps_plottings.find_by(id: params[:submission_id])
    return redirect_to gps_member_path if @submission.nil?

    @villages       = Village.ordered
    @hak_types      = HakType.ordered
    @act_fors       = GpsPlotting.act_fors
    @sub_districts  = SubDistrict.ordered

    @certificate_statuses = GpsPlotting.certificate_statuses
    submission_files = @submission.submission_files.group_by {|v| v.file_type}
    @images = submission_files.map do |image|
      {
        name: image[0],
        images: image[-1]
      }
    end
  end

  private

  def find_workspace
    @workspace = current_user.workspaces.find_by(id: params['id'])
    return redirect_to gps_workspaces_path unless @workspace
  end

  def gps_plotting_params
    params.permit(
      :act_for,
      :hay_type,
      :fullname,
      :lattitude,
      :longitude,
      :on_behalf,
      :hak_number,
      :land_address,
      :certificate_status,
      :alas_hak_number
    )
  end

  def create_workspace_params
    params.permit(
      :rt,
      :rw,
      :name,
      :village,
      :date_to,
      :district,
      :date_from,
      :sub_district
    )
  end
end
