require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe "validations" do
    it "is invalid without a first_name" do
      profile = Profile.new(first_name: "")
      profile.valid?
      expect(profile.errors).to have_key(:first_name)
    end

    it "is invalid without a last name" do
      profile = Profile.new(last_name: nil)
      profile.valid?
      expect(profile.errors).to have_key(:last_name)
    end
  end
  describe ".full_name" do
    let!(:user) {create :user}
    let!(:profile) {create :profile, first_name: "First", last_name: "Last", user: user}
    it "returns full name" do
      expect(profile.full_name).to eq "First Last"
    end
  end
end
