class IntipsController < ApplicationController
  layout 'dashboards'

  before_action :authenticate_user!
  before_action :find_member, only: [
    :edit_member,
    :detail_member,
    :detail_member,
    :delete_member,
    :process_edit_member,
    :intip_members_detail,
    :intip_members_permohonan
  ]

  def index
    intips = Intip.all.group_by{|v| [v.sub_district, v.village]}
    @results = []
    intips.each do |v|
      counts = Hash.new(0)
      v[1].each { |data| counts[data.status] += 1 }
      @results << {
        total: v[1].count,
        village: v[0][1].name,
        calcullate: counts.sort,
        sub_district: v[0][0].name
      }
    end
    @results
  end

  def members
    @last_query = params['q']['email_cont'] rescue ''
    @search     = member_intips.ransack(params[:q])
    @members    = @search.result.includes(:user_detail).page params[:page]
  end

  def detail_member
    @workspaces = @member.workspaces
  end

  def intip_members
    @members = member_intips
  end

  def intip_members_detail
    @workspaces = @member.workspaces
  end

  def intip_members_permohonan
    @workspace = Workspace.find_by(id: params['workspace_id'])
    @search = @workspace.intips.order(created_at: :desc).ransack(params[:q])
    @intips = @search.result.includes(:sub_district, :village).page params[:page]

    if params[:archive]
      shp_file_name = "permohonan-intip(#{Time.now.strftime('%d%m%Y-%H%M%S')})"
      ShpBuilder.generate_csv_shp_intip(@intips, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"permohonan-intip-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"permohonan-intip-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.html { render :intip_members_permohonan }
    end
  end

  def submissions
    @search = Intip.all.ransack(params[:q])
    @intips = @search.result.includes(:sub_district, :village).page params[:page]
  end

  def edit_member; end

  def process_edit_member
    @member.email     = params['email']
    @member.username  = params['username']
    @member.password  = params['password'] if params['password'].present?
    if @member.save
      @member.user_detail.update(fullname: params['fullname'], phone_number: params['phone_number'])
      flash[:notice] = 'Berhasil memperbaharui data member.'
      redirect_to intip_admin_members_path
    else
      flash[:errors] = @member.errors.full_messages
      redirect_to intip_admin_members_edit_url(@member)
    end
  end

  def delete_member
    @member.destroy
    flash[:notice] = 'Berhasil menghapus member.'
    redirect_to intip_admin_members_path
  end

  def create_member
    user = User.new(user_params)
    if user.save
      # user.skip_confirmation!
      UserDetail.create(user_id: user.id, fullname: params['fullname'], phone_number: params['phone_number'])
      UserRole.create(user_id: user.id, role_id: Role.member_intip_id)
      flash[:notice] = 'Berhasil menambahkan member baru.'
      redirect_to intip_admin_members_path
    else
      flash[:errors] = user.errors.full_messages
      redirect_to intip_admin_members_new_path
    end
  end

  private

  def find_member
    @member = User.find_by(id: params['id'])
  end

  def member_intips
    User.member_intip
  end

  def user_params
    params.permit(
      :email,
      :username,
      :password
    )
  end
end
