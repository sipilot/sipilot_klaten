module Api
  module V1
    class WorkingAreasController < Api::BaseController
      skip_before_action :authenticate

      def working_areas
        response = Area.select('id, name')
        api_success_response(response)
      end
    end
  end
end
