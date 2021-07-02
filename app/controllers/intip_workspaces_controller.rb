class IntipWorkspacesController < ApplicationController
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

  def process_data
    action_type = params['button'].downcase
    intips = current_user.intips.where(id: params['submission_ids'])
    if action_type == 'kirim'
      notice = "Berhasil mengirim #{intips.count} data."
      intips.update_all(sent_at: Time.now)
    end

    if action_type == 'hapus'
      notice = "Berhasil menghapus #{intips.count} data."
      intips.destroy_all
    end

    flash[:notice] = notice
    redirect_to session[:return_back]
  end

  def detail; end

  def new_submission
    @intp           = Intip.new
    @villages       = Village.ordered
    @hak_types      = HakType.ordered
    @act_fors       = Submission.act_fors
    @sub_districts  = SubDistrict.ordered
    @alas_types     = AlasType.ordered
    @certificate_statuses = GpsPlotting.certificate_statuses
    @workspace = current_user.workspaces.find_by(id: params['id'])
    session[:return_back] = request.fullpath
  end

  def process_new_submission
    workspace = current_user.workspaces.find(params['id'])
    intip = current_user.intips.new(intip_params)
    intip.workspace_id = workspace.id
    intip.alas_type_id = params['alas_type']
    intip.village_id = params['village'].to_i
    intip.hak_type_id = params['hak_type'].to_i
    intip.sub_district_id = params['sub_district'].to_i
    if intip.save
      flash[:notice] = 'Success submit intip.'
      redirect_to intips_member_workspaces_show_path(workspace.id)
    else
      flash[:errors] = intip.errors.full_messages
      redirect_to intips_member_workspaces_new_submission_path(workspace.id)
    end
  end

  def show
    @search = @workspace.intips.where('sent_at IS NULL').ransack(params[:q])
    @results = @search.result.page(params['page']).per(params['per'])
    session[:return_back] = request.fullpath
  end

  def delete
    @workspace.destroy
    redirect_to intips_workspaces_path
  end

  private

  def find_workspace
    @workspace = current_user.workspaces.find_by(id: params['id'])
    return redirect_to gps_workspaces_path unless @workspace
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

  def intip_params
    params.permit(
      :nui,
      :nib,
      :date,
      :name,
      :image,
      :status,
      :land_use,
      :longitude,
      :lattitude,
      :land_size,
      :hak_number,
      :time_range,
      :description,
      :land_address,
      :land_control,
      :land_allocation,
      :number_letter_c,
      :land_utilization,
      :alas_hak_number
    )
  end
end
