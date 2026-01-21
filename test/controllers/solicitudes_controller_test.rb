require "test_helper"

class SolicitudesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @solicitude = solicitudes(:one)
  end

  test "should get index" do
    get solicitudes_url
    assert_response :success
  end

  test "should get new" do
    get new_solicitude_url
    assert_response :success
  end

  test "should create solicitude" do
    assert_difference("Solicitude.count") do
      post solicitudes_url, params: { solicitude: { lastname: @solicitude.lastname, matter: @solicitude.matter, message: @solicitude.message, name: @solicitude.name, phone_number: @solicitude.phone_number, policies: @solicitude.policies } }
    end

    assert_redirected_to solicitude_url(Solicitude.last)
  end

  test "should show solicitude" do
    get solicitude_url(@solicitude)
    assert_response :success
  end

  test "should get edit" do
    get edit_solicitude_url(@solicitude)
    assert_response :success
  end

  test "should update solicitude" do
    patch solicitude_url(@solicitude), params: { solicitude: { lastname: @solicitude.lastname, matter: @solicitude.matter, message: @solicitude.message, name: @solicitude.name, phone_number: @solicitude.phone_number, policies: @solicitude.policies } }
    assert_redirected_to solicitude_url(@solicitude)
  end

  test "should destroy solicitude" do
    assert_difference("Solicitude.count", -1) do
      delete solicitude_url(@solicitude)
    end

    assert_redirected_to solicitudes_url
  end
end
