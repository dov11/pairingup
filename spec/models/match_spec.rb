require 'rails_helper'

RSpec.describe Match, type: :model do
  describe ".create_array_of_pairings" do
    students = ["1", "2", "3", "4"]
    let!(:user1) {create :user, email: "user1@gmail.com", password: "123456", admin: false}
    let!(:user2) {create :user, email: "user2@gmail.com", admin: false}
    let!(:user3) {create :user, email: "user3@gmail.com", admin: false}
    let!(:user4) {create :user, email: "user4@gmail.com", admin: false}
    # let!(:user5) {create :user, email: "user5@gmail.com", admin: false}
    # let!(:user6) {create :user, email: "user6@gmail.com", admin: false}

    let!(:profile1) {create :profile, first_name: "1", last_name: "A", user: user1}
    let!(:profile2) {create :profile, first_name: "2", last_name: "B", user: user2}
    let!(:profile3) {create :profile, first_name: "3", last_name: "C", user: user3}
    let!(:profile4) {create :profile, first_name: "4", last_name: "D", user: user4}
    # let!(:profile5) {create :profile, first_name: "5", last_name: "E", user: user5}
    # let!(:profile6) {create :profile, first_name: "6", last_name: "F", user: user6}

    it "returnes all possible combinations" do
      expect(Match.create_array_of_pairings(Match.students_names).map{|hash| hash.to_a}.flatten.sort)
      .to eq [{"1 A"=>"2 B", "3 C"=>"4 D"}, {"1 A"=>"3 C", "2 B"=>"4 D"}, {"1 A"=>"4 D", "2 B"=>"3 C"}].map{|hash| hash.to_a}.flatten.sort
    end
  end
end
