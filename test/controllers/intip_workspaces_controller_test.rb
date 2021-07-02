require 'test_helper'

class IntipWorkspacesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get intip_workspaces_index_url
    assert_response :success
  end

end
