require "test_helper"

class UserLockoutTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def attempt_sign_in(user, password)
    post user_session_url, params: { user: { email: user.email, password: password } }
  end

  test "five failed sign-ins lock the account even with the right password" do
    user = users(:dadi_head)
    Devise.maximum_attempts.times { attempt_sign_in(user, "equivocada") }
    assert user.reload.access_locked?

    attempt_sign_in(user, "password")
    assert_response :unprocessable_entity
    assert_match "bloqueada", flash[:alert]
  end

  test "the account unlocks itself after an hour" do
    user = users(:dadi_head)
    user.lock_access!(send_instructions: false)

    travel Devise.unlock_in + 1.minute do
      attempt_sign_in(user, "password")
      assert_redirected_to dashboard_index_url
    end
  end

  test "dtic can unlock an account right away" do
    user = users(:dadi_head)
    user.lock_access!(send_instructions: false)
    sign_in users(:dtic_head)

    get users_url
    assert_select ".badge", "Bloqueada"
    assert_select "button[title=Desbloquear]", 1

    patch unlock_user_url(user)
    assert_not user.reload.access_locked?
  end

  test "someone who cannot edit users cannot unlock them" do
    user = users(:dtic_head)
    user.lock_access!(send_instructions: false)
    sign_in users(:dadi_head)

    patch unlock_user_url(user)
    assert user.reload.access_locked?
  end

  test "the session ends after an hour without activity" do
    sign_in users(:dtic_head)
    get general_setup_url
    assert_response :success

    travel Devise.timeout_in + 1.minute do
      get general_setup_url
      follow_redirect!
      assert_redirected_to new_user_session_url
    end
  end
end
