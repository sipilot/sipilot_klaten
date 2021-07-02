class GpsController < ApplicationController
  layout 'dashboards'

  skip_before_action :check_open_office
  before_action :authenticate_user!
  before_action :set_ransact_value, only: [:gps_members_permohonan]
  before_action :find_member, only: [
    :edit_member,
    :delete_member,
    :detail_member,
    :gps_members_detail,
    :process_edit_member,
    :gps_members_permohonan,
    :delete_workspace_member
  ]

  def index
    gps_plottings = GpsPlotting.ordered.group_by{ |v| [v.sub_district, v.village] }
    @results = []
    gps_plottings.each do |v|
      @results << {
        total: v[1].count,
        village: v[0][1].name,
        sub_district: v[0][0].name
      }
    end
    @results
  end

  def gps_members
    @members = member_gps
    @search = GpsPlotting.where('sent_at IS NOT NULL').order(created_at: :desc).ransack(params[:q])
    @gps_plottings = @search.result.includes(:sub_district, :village).page params[:page]
  end

  def gps_members_detail
    @workspaces = @member.workspaces
  end

  def delete_workspace_member
    workspace = @member.workspaces.find_by(id: params[:workspace_id])
    if workspace.destroy
      flash[:notice] = 'Berhasil menghapus workspace.'
      redirect_to gps_admin_gps_members_detail_path(@member)
    else
      flash[:errors] = @member.errors.full_messages
      redirect_to gps_admin_gps_members_detail_path(@member)
    end
  end

  def gps_members_permohonan
    @workspace = Workspace.find_by(id: params['workspace_id'])
    @search = @workspace.gps_plottings.where('sent_at IS NOT NULL').order(created_at: :desc).ransack(params[:q])
    @gps_plottings = @search.result.includes(:sub_district, :village).page params[:page]

    if params[:archive]
      shp_file_name = "permohonan-gps(#{Time.now.strftime('%d%m%Y-%H%M%S')})"
      ShpBuilder.generate_csv_shp_gps(@gps_plottings, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"permohonan-gps-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"permohonan-gps-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :gps_members_permohonan }
    end
  end

  def detail
    @gps_plotting = GpsPlotting.find_by(id: params['id'])
  end

  def members
    @last_query = params['q']['email_cont'] rescue ''
    @search     = member_gps.ransack(params[:q])
    @members    = @search.result.includes(:user_detail).page params[:page]
  end

  def edit_member; end

  def detail_member
    @workspaces = @member.workspaces
  end

  def process_edit_member
    @member.password = params['password'] if params['password'].present?
    if @member.save
      flash[:notice] = 'Berhasil memperbaharui data member.'
      redirect_to gps_admin_members_path
    else
      flash[:errors] = @member.errors.full_messages
      redirect_to gps_admin_members_edit_url(@member)
    end
  end

  def delete_member
    @member.destroy
    flash[:notice] = 'Berhasil menghapus member.'
    redirect_to gps_admin_members_path
  end

  def create_member
    user = User.new(user_params)
    if user.save
      # user.skip_confirmation!
      UserDetail.create(user_id: user.id, fullname: params['fullname'], phone_number: params['phone_number'])
      UserRole.create(user_id: user.id, role_id: Role.member_gps_id)
      flash[:notice] = 'Berhasil menambahkan member baru.'
      redirect_to gps_admin_members_path
    else
      flash[:errors] = user.errors.full_messages
      redirect_to gps_admin_members_new_path
    end
  end

  def self.date
    created_at.strftime('%d %B %Y')
  end

  private

  def member_gps
    User.member_gps
  end

  def find_member
    @member = User.find_by(id: params['id'])
  end

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
  end

  def user_params
    params.permit(
      :email,
      :username,
      :password
    )
  end
end
