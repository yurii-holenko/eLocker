class HomeController < ApplicationController
  def index
    @postgres_version = ActiveRecord::Base.connection.select_value("SHOW server_version")
  end
end
