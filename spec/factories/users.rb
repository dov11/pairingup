FactoryGirl.define do
  factory :user do
    email    { Faker::Internet.email }
    password { Faker::Internet.password }
    admin {Faker::Boolean.boolean}
  end
end
