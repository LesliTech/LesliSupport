require 'test_helper'

module CloudHelp
  class SlasControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @sla = cloud_help_slas(:one)
    end

    test "should get index" do
      get slas_url
      assert_response :success
    end

    test "should get new" do
      get new_sla_url
      assert_response :success
    end

    test "should create sla" do
      assert_difference('Sla.count') do
        post slas_url, params: { sla: {  } }
      end

      assert_redirected_to sla_url(Sla.last)
    end

    test "should show sla" do
      get sla_url(@sla)
      assert_response :success
    end

    test "should get edit" do
      get edit_sla_url(@sla)
      assert_response :success
    end

    test "should update sla" do
      patch sla_url(@sla), params: { sla: {  } }
      assert_redirected_to sla_url(@sla)
    end

    test "should destroy sla" do
      assert_difference('Sla.count', -1) do
        delete sla_url(@sla)
      end

      assert_redirected_to slas_url
    end
  end
end
