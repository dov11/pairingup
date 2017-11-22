class PagesController < ApplicationController
  def home
    redirect_to matches_path unless current_user.try(:admin?)
  end
end
