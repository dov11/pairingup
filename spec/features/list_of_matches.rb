require 'rails_helper'

def set_date_and_create_match(year, month, day)
  select "#{year}", from: "match_pairing_date_1i"
  select month, from: "match_pairing_date_2i"
  select "#{day}", from: "match_pairing_date_3i"
  click_on("Create matches")
end
describe "Current user viewing the list of matches" do
  before { login_as admin }
  let!(:admin) {create :user, email: "admin_@gmail.com", admin: true}
  let!(:user1) {create :user, email: "user1@gmail.com", admin: false}
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
  it "shows random admin matches" do
    visit matches_url

    set_date_and_create_match(2017, "November", 22)
    set_date_and_create_match(2017, "November", 23)
    set_date_and_create_match(2017, "November", 26)
    set_date_and_create_match(2017, "November", 28)
    set_date_and_create_match(2017, "November", 29)

    expect(page).to have_content("1 A ---- 2 B").or(have_content("2 B ---- 1 A"))
    expect(page).to have_content("1 A ---- 3 C").or(have_content("3 C ---- 1 A"))
    expect(page).to have_content("1 A ---- 4 D").or(have_content("4 D ---- 1 A"))
    expect(page).to have_content("1 A ---- 5 E").or(have_content("5 E ---- 1 A"))
    expect(page).to have_content("1 A ---- 6 F").or(have_content("6 F ---- 1 A"))

  end


end
