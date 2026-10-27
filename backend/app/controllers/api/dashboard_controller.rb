module Api
  class DashboardController < BaseController
    def summary
      render json: Dashboard::Summary.new(current_account).as_json
    end
  end
end
