require 'test_helper'

class SuperAdminsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get super_admins_index_url
    assert_response :success
  end

end
