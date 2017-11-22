class MatchesController < ApplicationController
  def index
    @matches = get_matches
    @partner = partner_of_the_day unless current_user.try(:admin?)
  end

  def show
    @match= current_user.try(:admin?) ? get_match : get_match.users_partner(user_full_name)
  end

  def create
    if current_user.try(:admin?)
      @match = Match.create_match(pairing_date)
      redirect_to matches_path
    else
      redirect_to matches_path, notice: "Please don't"
    end
  end

  private
  def user_full_name
    current_user.profile.full_name
  end
  def get_match
    if current_user.try(:admin?)
      @match=Match.find(params[:id])
    else
      @match=Match.find(params[:id]).select_my_pairings(current_user)
    end
  end

  def get_matches
    if current_user.try(:admin?)
      @matches = Match.sort_by_created_asc.all
    else
      @matches = Match.all.show_my_matches(current_user)
    end
  end

  def partner_of_the_day
    Match.show_match_of_the_day.users_partner(current_user)
  end

  def pairing_date
    year = params[:match]["pairing_date(1i)"].to_i
    month = params[:match]["pairing_date(2i)"].to_i
    day = params[:match]["pairing_date(3i)"].to_i
    date = DateTime.new(year, month, day)
  end
end
