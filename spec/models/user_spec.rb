require 'rails_helper'

RSpec.describe User, type: :model do
  describe "user can be an admin or a student" do
    let!(:admin) {create :user, admin: true}
    let!(:student) {create :user}
    it "checks if user is an admin or a user" do
      expect(admin.try(:admin?)).to eq true
      expect(student.try(:admin?)).to eq false
    end
  end
end
