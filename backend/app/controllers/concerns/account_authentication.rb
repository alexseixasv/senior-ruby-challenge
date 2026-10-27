module AccountAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_account!
  end

  private

  def authenticate_account!
    account = Account.find_by(id: account_id_from_token)
    if account.nil?
      render json: { error: "unauthorized" }, status: :unauthorized
      return
    end

    @current_account = account
  end

  def current_account
    @current_account
  end

  def account_id_from_token
    header = request.authorization.to_s
    token = header.sub(/\ABearer\s+/i, "")
    token.match(/\Ademo-account-(\d+)\z/)&.[](1)
  end
end
