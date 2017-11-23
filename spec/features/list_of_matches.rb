require 'rails_helper'

def set_date_and_create_match(day)
  select "#{Time.now.year}", from: "match_pairing_date_1i"
  select I18n.t("date.month_names")[Date.today.month], from: "match_pairing_date_2i"
  select "#{day}", from: "match_pairing_date_3i"
  click_on("Create matches")
end

def set_day(day)
  days = [
    (Time.now-1.day).day,
    Time.now.day,
    (Time.now+2.day).day,
    (Time.now+4.day).day,
    (Time.now+5.day).day
  ]
  days[day]
end

def create_five_matches
  5.times { |i| set_date_and_create_match(set_day(i))}
end

def create_four_matches
  4.times { |i| set_date_and_create_match(set_day(i+1))}
end

def expect_five_different_matches
  expect(page).to have_content("1 A ---- 2 B").or(have_content("2 B ---- 1 A"))
  expect(page).to have_content("2 B ---- 3 C").or(have_content("3 C ---- 2 B"))
  expect(page).to have_content("2 B ---- 4 D").or(have_content("4 D ---- 2 B"))
  expect(page).to have_content("2 B ---- 5 E").or(have_content("5 E ---- 2 B"))
end

def expect_only_two_matches
  match_of_today = "#{Time.now.year}-#{Time.now.month}-#{Time.now.day}"
  match_of_yesterday = "#{Time.now.year}-#{Time.now.month}-#{(Time.now-1.day).day}"
  match_of_tomorrow = "#{Time.now.year}-#{Time.now.month}-#{(Time.now+2.day).day}"
  expect(page).to have_content(match_of_today)
  expect(page).to have_content(match_of_yesterday)
  expect(page).to have_no_content(match_of_tomorrow)
end

def login(email, password)
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Log in"
end

def find_pairing(day)
  click_on("#{Time.now.year}-#{Time.now.month}-#{day}")

  pairing = all('p').each { |a| a[:html] }
  pairing = pairing.map{|a| a.text}
  visit matches_url
  return pairing
end

# def find_two_pairings
#   find_pairing(today_day)
# end

describe "Current user viewing the list of matches" do
  before { login_as admin }
  let!(:admin) {create :user, email: "admin_@gmail.com", admin: true}
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

  it "shows random admin matches" do
    visit matches_url

    create_five_matches

    expect_five_different_matches
  end

  # it "regenerates random 5 matches" do
  #   visit matches_url
  #   # set_date_and_create_match(set_day(0))
  #   # set_date_and_create_match(set_day(1))
  #   # set_date_and_create_match(set_day(2))
  #   # # set_date_and_create_match(set_day(3))
  #   # # set_date_and_create_match(set_day(4))
  #   next_day = set_day(2)
  #   today_day = set_day(1)
  #
  #   two_pairings1 = find_pairing(today_day).concat(find_pairing(next_day))
  #
  #   set_date_and_create_match(today_day)
  #
  #   expect_five_different_matches
  #
  #   two_pairings2 = find_pairing(today_day).concat(find_pairing(next_day))
  #
  #   expect(two_pairings1).not_to eql(two_pairings2)
  # end
  it "generates random 5 matches after regenerating first" do
    visit matches_url

    set_date_and_create_match(set_day(0))
    set_date_and_create_match(set_day(0))

    create_four_matches
    expect_five_different_matches
  end

  # it "generates 4 matches, regenerates them, adds one more" do
  #   visit matches_url
  #   create_four_matches
  #   set_date_and_create_match(set_day(1))
  #   set_date_and_create_match(set_day(1))
  #   set_date_and_create_match(set_day(4))
  #   expect_five_different_matches
  #
  # end

  it "only mutates first 5 matches" do
    visit matches_url

    create_five_matches
    set_date_and_create_match((Time.now+6.day).day)
    pairing1_before = find_pairing((Time.now+6.day).day)
    two_pairings_before = find_pairing(set_day(1)).concat(find_pairing(set_day(2)))
    set_date_and_create_match(set_day(0))
    pairing1_after = find_pairing((Time.now+6.day).day)
    two_pairings_after = find_pairing(set_day(1)).concat(find_pairing(set_day(2)))
# byebug
    expect(pairing1_before).to eql(pairing1_after)
    expect(two_pairings_before).not_to eql(two_pairings_after)
  end

  it "student sees only past matches" do
    visit matches_url

    create_five_matches

    click_on("Log out")

    login("user1@gmail.com", "123456")

    expect_only_two_matches
    expect(page).to have_content("Your partner for today:")
  end


end
