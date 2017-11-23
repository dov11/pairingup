require 'rails_helper'

RSpec.describe Match, type: :model do
  # before(:each) do
  #  end
  describe ".create_array_of_pairings" do
    let!(:user1) {create :user, email: "user1@gmail.com", password: "123456", admin: false}
    let!(:user2) {create :user, email: "user2@gmail.com", admin: false}
    let!(:user3) {create :user, email: "user3@gmail.com", admin: false}
    let!(:user4) {create :user, email: "user4@gmail.com", admin: false}
    let!(:user5) {create :user, email: "user5@gmail.com", admin: false}
    let!(:user6) {create :user, email: "user6@gmail.com", admin: false}

    let!(:profile1) {create :profile, first_name: "1", last_name: "A", user: user1}
    let!(:profile2) {create :profile, first_name: "2", last_name: "B", user: user2}
    let!(:profile3) {create :profile, first_name: "3", last_name: "C", user: user3}
    let!(:profile4) {create :profile, first_name: "4", last_name: "D", user: user4}
    let!(:profile5) {create :profile, first_name: "5", last_name: "E", user: user5}
    let!(:profile6) {create :profile, first_name: "6", last_name: "F", user: user6}
    def possible_combinations_flat
      [
        {"1 A"=>"2 B", "3 C"=>"4 D", "5 E"=> "6 F"},
        {"1 A"=>"3 C", "2 B"=>"6 F", "4 D"=> "5 E"},
        {"1 A"=>"4 D", "2 B"=>"5 E", "3 C"=> "6 F"},
        {"1 A"=>"5 E", "2 B"=>"3 C", "4 D"=>"6 F"},
        {"1 A"=>"6 F", "2 B"=>"4 D", "3 C"=>"5 E"}
      ].map{|hash| hash.to_a}.flatten.sort
    end
    def create_five_matches
      Match.create_match(DateTime.new(2017,11,22))
      Match.create_match(DateTime.new(2017,11,23))
      Match.create_match(DateTime.new(2017,11,24))
      Match.create_match(DateTime.new(2017,11,25))
      Match.create_match(DateTime.new(2017,11,26))
    end
    def pairings_as_array_of_arrays
      Match.all.map{|match| match[:pairing].to_a}
    end
    it "returnes all possible combinations" do
      expect(Match.create_array_of_pairings(Match.students_names)
      .map{|hash| hash.to_a}
      .flatten.sort)
      .to eq possible_combinations_flat
    end
    it "creates consequent matches" do
      Match.class_eval {class_variable_set :@@pairings, Match.create_array_of_pairings(Match.students_names)}
      create_five_matches
      expect(Match.first[:pairing_date]).to eq(DateTime.new(2017,11,22))
      expect(Match.last[:pairing_date]).to eq(DateTime.new(2017,11,26))
      expect(pairings_as_array_of_arrays.flatten.sort)
      .to eq possible_combinations_flat
    end
    it "overwrightes 5 matches" do
      Match.destroy_all
      Match.class_eval {class_variable_set :@@pairings, Match.create_array_of_pairings(Match.students_names)}

      create_five_matches
      pairings_before = pairings_as_array_of_arrays
      Match.create_match(DateTime.new(2017,11,22))
      pairings_after = pairings_as_array_of_arrays

      expect(pairings_as_array_of_arrays.flatten.sort)
      .to eq possible_combinations_flat

      expect(pairings_before).not_to eq pairings_after
    end
  end
end
