require 'rails_helper'

def set_date_and_create_match(day)
  select "#{Time.now.year}", from: "match_pairing_date_1i"
  select I18n.t("date.month_names")[Date.today.month], from: "match_pairing_date_2i"
  select "#{day}", from: "match_pairing_date_3i"
  click_on("Create matches")
end

def create_five_matches
  set_date_and_create_match((Time.now-1.day).day)
  set_date_and_create_match(Time.now.day)
  set_date_and_create_match((Time.now+2.day).day)
  set_date_and_create_match((Time.now+4.day).day)
  set_date_and_create_match((Time.now+5.day).day)
end

def expect_five_different_mathes
  expect(page).to have_content("1 A ---- 2 B").or(have_content("2 B ---- 1 A"))
  expect(page).to have_content("1 A ---- 3 C").or(have_content("3 C ---- 1 A"))
  expect(page).to have_content("1 A ---- 4 D").or(have_content("4 D ---- 1 A"))
  expect(page).to have_content("1 A ---- 5 E").or(have_content("5 E ---- 1 A"))
  expect(page).to have_content("1 A ---- 6 F").or(have_content("6 F ---- 1 A"))
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

    create_five_matches

    expect_five_different_mathes

  end

  it "regenerates random matches" do
    visit matches_url

    create_five_matches

    expect_five_different_mathes

    set_date_and_create_match(Time.now.day)

    expect_five_different_mathes

  end


end
