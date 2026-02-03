class DashboardController < ApplicationController
  # Authentication with Devise before any action
  before_action :authenticate_user!

  def index
  end
end
