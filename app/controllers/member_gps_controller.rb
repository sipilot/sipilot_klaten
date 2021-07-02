class MemberGpsController < ApplicationController
  layout 'dashboards'

  skip_before_action :check_open_office
  before_action :authenticate_user!
  before_action :set_form_data, only: [
    :new_gps_submission,
    :edit_gps_submission
  ]
  before_action :find_gps_plotting, only: [
    :edit_gps_submission,
    :detail_gps_submission,
    :edit_process_gps_submission
  ]
  before_action :set_submitted_params, only: [:gps]
  before_action :find_liat_gps_plottings, only: [
    :process_data,
    :sent_gps_submission,
    :delete_completed_gps,
    :delete_gps_submission
  ]

  def index
    gps_plottings = current_user.gps_plottings.group_by { |v| [v.sub_district, v.village] }
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

  def permohonan
    @search = current_user.gps_plottings_today.ransack(params[:q])
    @gps_plottings = @search.result.includes(:sub_district, :village).page params[:page]
  end

  def gps
    village_ids = current_user.workspaces.pluck(:village_id).uniq
    @villages = Village.where(id: village_ids).ordered
    @search = current_user.gps_plottings.where('sent_at IS NULL').ransack(params[:q])
    @gps_plottings = @search.result.includes(:sub_district, :village).page params[:page]
    session[:return_back] = request.fullpath
  end

  def sent_gps_submission
    @submissions.update_all(sent_at: Time.now, status: 'selesai')
    flash[:notice] = 'Permohonan berhasil dikirim.'
    redirect_to session[:return_back]
  end

  def detail_gps_submission; end

  def new_gps_submission; end

  def submit_gps_submission
    gps = current_user.gps_plottings.new(gps_plotting_params)
    gps.hak_type_id     = params['hak_type']
    gps.village_id      = params['village'].to_i
    gps.sub_district_id = params['sub_district'].to_i
    if gps.save
      gps.process_submission_image_nested(
        params['land_book'],
        params['measuring_letter'],
        params['id_number'],
        params['authority_letter'],
        params['alas_hak'],
        params['ground_sketch']
      )
      redirect_to gps_member_permohonan_path
    else
      flash[:errors] = gps.errors.full_messages
      redirect_to session[:return_back]
    end
  end

  def process_data
    action_type = params['button'].downcase
    if action_type == 'hapus'
      notice = "Berhasil menghapus #{@submissions.count} data."
      @submissions.destroy_all
    end

    flash[:notice] = notice
    redirect_to session[:return_back]
  end

  def completed_gps
    @search = current_user.gps_plottings.where('sent_at IS NOT NULL').order(created_at: :desc).ransack(params[:q])
    @gps_plottings = @search.result.includes(:sub_district, :village).page params[:page]
    session[:return_back] = request.fullpath
    @submissions_exports = @gps_plottings
    @villages = Village.where('id IN(select village_id from workspaces where user_id = ?)', current_user.id).ordered

    if params[:archive] && @gps_plottings
      shp_file_name = "berkas-selesai(#{Time.now.strftime('%d%m%Y-%H%M%S')})"
      ShpBuilder.generate_csv_shp(@gps_plottings, shp_file_name)

      p '------====== PYTHON CREATE SHP ======------'
      p `python3 lib/python/create_shapefile.py "#{shp_file_name}"`
      p '------====== *** ======------'

      zip_path = ShpBuilder.create_zip_file(shp_file_name)
      send_data(zip_path, type: 'application/zip', filename: "#{shp_file_name}.zip")

      return
    end

    respond_to do |format|
      format.pdf do
        headers['Content-Disposition'] = "attachment; filename=\"berkas-selesai-#{Formatter.date_dmy(Time.now)}.pdf\""
      end
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"berkas-selesai-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
      format.html { render :completed_gps }
    end
  end

  def delete_completed_gps
    @submissions.destroy_all
    flash[:notice] = 'Permohonan berhasil dihapus.'
    redirect_to session[:return_back]
  end

  def delete_gps_submission
    @submissions.destroy_all
    flash[:notice] = 'Permohonan berhasil dihapus.'
    redirect_to session[:return_back]
  end

  def edit_gps_submission
    submission_files = @gps_plotting.submission_files.group_by(&:file_type)
    @images = submission_files.map do |image|
      {
        name: image[0],
        images: image[-1]
      }
    end
  end

  def edit_process_gps_submission
    @gps_plotting.update(edit_gps_plotting_params)
    @gps_plotting.hak_type_id     = params['hak_type']
    @gps_plotting.village_id      = params['village'].to_i
    @gps_plotting.sub_district_id = params['sub_district'].to_i
    if @gps_plotting.save
      @gps_plotting.process_submission_update_image_nested(
        params['land_book'],
        params['measuring_letter'],
        params['id_number'],
        params['authority_letter'],
        params['alas_hak'],
        params['ground_sketch']
      )
      flash[:notice] = 'Permohonan berhasil dirubah'
      redirect_to session[:return_back]
    end
  end

  private

  def set_submitted_params
    @village_id   = params['q']['village_id_eq'] rescue ''
    @name_params  = params['q']['name_matches'] rescue ''
    @lteq_params  = params['q']['created_at_lteq'] rescue ''
    @gteq_params  = params['q']['created_at_gteq'] rescue ''
    @village_params = params['q']['village_name_matches'] rescue ''
    @sub_district_params = params['q']['sub_district_name_matches'] rescue ''
  end

  def find_gps_plotting
    @gps_plotting = current_user.gps_plottings.find_by(id: params[:id])
    return redirect_to gps_member_path if @gps_plotting.nil?
  end

  def find_liat_gps_plottings
    @submissions = current_user.gps_plottings.where(id: params['submission_ids'])
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
      :certificate_status
    )
  end

  def edit_gps_plotting_params
    params.permit(
      :act_for,
      :hay_type,
      :fullname,
      :lattitude,
      :longitude,
      :on_behalf,
      :hak_number,
      :land_address,
      :certificate_status
    )
  end

  def set_form_data
    @villages       = Village.ordered
    @hak_types      = HakType.ordered
    @act_fors       = GpsPlotting.act_fors
    @sub_districts  = SubDistrict.ordered
    @certificate_statuses = GpsPlotting.certificate_statuses
  end
end
