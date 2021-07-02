class Api::V1::MembersController < Api::BaseController
  def create_validations
  end

  def index
    validations   = current_user_api.submissions.list_validation
    space_pattern = current_user_api.submissions.list_space_pattern
    @data = [
      {
        type: 'validations',
        total: validations.count,
        done: validations.where(submission_status: 'selesai').count,
        process: validations.where(submission_status: 'proses').count,
        revisions: validations.where(submission_status: 'revisi').count
      },
      {
        type: 'space pattern',
        total: space_pattern.count,
        done: space_pattern.where(submission_status: 'selesai').count,
        process: space_pattern.where(submission_status: 'proses').count,
        revisions: space_pattern.where(submission_status: 'revisi').count
      }
    ]

    return api_success_response(@data) unless params[:export]

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"permohonan-#{Formatter.date_dmy(Time.now)}.xlsx\""
      }
    end
  end

  def validations
    validations = current_user_api.submissions.list_validation.page(params['page']).per(params['per'])
    response = validations.map do |validation|
      {
        id: validation.id,
        act_for: validation.act_for,
        hak_type: validation.hak_name,
        fullname: validation.fullname,
        on_behalf: validation.on_behalf,
        lattitude: validation.lattitude,
        longitude: validation.longitude,
        address: validation.land_address,
        code: validation.submission_code,
        village: validation.village_name,
        hak_number: validation.hak_number,
        sub_district: validation.sub_district_name,
        files: validation.submission_files.map do |file|
          {
            id: file.id,
            type: file.file_type,
            image: url_for(file.image)
          }
        end
      }
    end

    api_success_response(response)
  end

  def submission_recaps
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

  private

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
