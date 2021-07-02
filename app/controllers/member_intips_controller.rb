class MemberIntipsController < ApplicationController
  layout 'dashboards'

  before_action :authenticate_user!
  before_action :set_data, only: [:new_intip_submission, :new_intip_submission]

  def index
    @search = current_user.intips_today.ransack(params[:q])
    @intips = @search.result.includes(:sub_district, :village).page params[:page]
  end

  def show
    @intip = current_user.intips.find_by(id: params[:id])
  end

  def intip
    @name_params = params['q']['name_matches'] rescue ''
    @lteq_params = params['q']['created_at_lteq'] rescue ''
    @gteq_params = params['q']['created_at_gteq'] rescue ''
    @village_params = params['q']['village_name_matches'] rescue ''
    @sub_district_params = params['q']['sub_district_name_matches'] rescue ''

    village_ids = current_user.workspaces.pluck(:village_id).uniq
    @villages = Village.where(id: village_ids)

    @search = current_user.intips.ransack(params[:q])
    @intips = @search.result.includes(:sub_district, :village).page params[:page]
  end

  def intip_submission
    @search = current_user.intips.where('sent_at IS NOT NULL').ransack(params[:q])
    @intips = @search.result.includes(:sub_district, :village).page params[:page]

    village_ids = current_user.workspaces.pluck(:village_id).uniq
    @villages = Village.where(id: village_ids)
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

  def submit_intip_submission
    intip = current_user.intips.new(intip_params)
    intip.sub_district_id = params['sub_district'].to_i
    intip.village_id = params['village'].to_i
    if intip.save
      flash[:notice] = 'Success submit intip.'
      redirect_to intip_member_permohonan_path
    else
      flash[:errors] = intip.errors.full_messages
      redirect_to intip_member_permohonan_new_path
    end
  end

  def new_intip_submission
    @workspace = current_user.workspaces.find_by(id: params['id'])
    session[:return_back] = request.fullpath
  end

  private

  def set_data
    @intp           = Intip.new
    @villages       = Village.ordered
    @hak_types      = HakType.ordered
    @act_fors       = Submission.act_fors
    @sub_districts  = SubDistrict.ordered
  end

  def intip_params
    params.permit(
      :nui,
      :nib,
      :date,
      :name,
      :image,
      :status,
      :hak_type,
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
    )
  end
end
