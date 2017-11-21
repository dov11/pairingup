class MatchesController < ApplicationController
  def index
    @matches = Match.sort_by_created_asc.all
    @match  = Match.create_match(Time.new)
  end

  def show
    @match=Match.find(params[:id])
  end

  def create
    byebug
    @match = Match.create_match(pairing_date)
    redirect_to matches_path
  end

  private
  def pairing_date
    year = params[:match]["pairing_date(1i)"].to_i
    month = params[:match]["pairing_date(2i)"].to_i
    day = params[:match]["pairing_date(3i)"].to_i
    date = DateTime.new(year, month, day)
  end
end
