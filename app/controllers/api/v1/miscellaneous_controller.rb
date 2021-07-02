class Api::V1::MiscellaneousController < Api::BaseController
  skip_before_action :authenticate

  def haks
    type = params['type']
    data ||= HakType.without_certificate_status.ordered if type == 'validation'
    data ||= HakType.without_certificate_status.ordered if type == 'gps'
    data ||= HakType.ordered if type == 'space_pattern'
    data ||= HakType.ordered

    api_success_response(data)
  end

  def sub_district
    data ||= SubDistrict.select('id, name').where(district_id: params['district_id']).ordered if params['district_id'].present?
    data ||= SubDistrict.select('id, name').ordered

    api_success_response(data)
  end

  def working_areas
    areas = Area.select('id, name, base_url')
    response = areas.map do |area|
      {
        id: area.id,
        name: area.name,
        base_url: area.base_url.nil? ? '' : area.base_url
      }
    end
    api_success_response(response)
  end

  def areas
    areas = Area.select('id, area_id, name').ordered
    api_success_response(areas)
  end

  def villages
    data ||= Village.select('id, name').where(sub_district_id: params['sub_district_id']).ordered if params['sub_district_id'].present?
    data ||= Village.select('id, name').ordered
    api_success_response(data)
  end

  def alas_types
    data = AlasType.select('id, name, description').ordered
    api_success_response(data)
  end

  def act_fors
    data = Submission.act_fors
    results = data.map do |act|
      {
        id: act[1],
        name: act[0]
      }
    end
    api_success_response(results)
  end

  def certificate_status
    data = GpsPlotting.certificate_statuses
    results = data.map do |status|
      {
        id: status[1],
        name: status[0]
      }
    end
    api_success_response(results)
  end

  def districts
    data = District.select('id, name').ordered
    api_success_response(data)
  end
end
