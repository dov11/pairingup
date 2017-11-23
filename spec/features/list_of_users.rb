require 'rails_helper'
describe "Current user viewing the list of users" do
  before { login_as admin }
  let!(:admin) {create :user, email: "admin_@gmail.com", admin: true}
  let!(:user1) {create :user, email: "user1@gmail.com", password: "123456", admin: false}
  let!(:user2) {create :user, email: "user2@gmail.com", admin: false}

  let!(:adminProfile) {create :profile, first_name: "Admin", last_name: "The Admin", user: admin}
  let!(:profile1) {create :profile, first_name: "1", last_name: "A", user: user1}
  let!(:profile2) {create :profile, first_name: "2", last_name: "B", user: user2}

  it "allows admin to see profiles of users" do
    visit root_url
    click_link('Users')

    # expect(page).to have_content('Admin User')
    # expect(page).to have_content('Student')

    all('input').each {|input| click_on(in)}
    # click_on('Student')

    expect(page).to have_content('Admin')
    expect(page).to have_no_content('Student')
  end

end
