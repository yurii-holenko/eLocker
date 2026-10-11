module SessionHelpers
  # Authentication is mocked, so "signing in" is picking a user in the header dropdown.
  def sign_in_as(user)
    patch session_path, params: { user_id: user.id }
  end
end
