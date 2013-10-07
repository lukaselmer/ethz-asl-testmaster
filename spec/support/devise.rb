module RequestHelper
  def sign_in(user)
    post user_session_path(user: {email: user.email, password: user.password})
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include RequestHelper, type: :request
end
