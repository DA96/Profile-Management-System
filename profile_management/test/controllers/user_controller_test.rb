require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "should get get_profile" do
    get user_get_profile_url
    assert_response :success
  end

  test "should get edit_profile" do
    get user_edit_profile_url
    assert_response :success
  end

end
