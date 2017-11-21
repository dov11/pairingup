class ProfilesController < ApplicationController
  before_action :set_profile, only: [:index, :edit, :update]

  def index
    if current_user.try(:admin?)
      @profiles = Profile.all
    else
      redirect_to root_path, notice: "You do not have access"
    end
  end

  def new
    @profile = Profile.new
  end

  def create
    if current_user.try(:admin?) && profile_params[:user]
      @user = User.find(profile_params[:user])
      @user.admin = @user.admin ? false : true
      @user.save
      redirect_to profiles_path
    else
      @profile = current_user.build_profile(profile_params)
      if @profile.save
        redirect_to edit_profile_path(@profile), notice: "Profile successfully created"
      else
        render :new
      end
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to edit_profile_path(@profile), notice: "Profile successfully updated"
    else
      render :edit
    end
  end

  private
  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    if current_user.try(:admin?)
      params
    else
      params.require(:profile).permit(:first_name, :last_name, :bio)
    end
  end

  # def profile_full_names
  #   Profile.all.map{|profile| profile.full_name}
  # end
end
