Profile.destroy_all
Match.destroy_all
User.destroy_all

admin = User.create!(email: "admin@gmail.com", password: "123456", admin: true)
student1 = User.create!(email: "example@gmail.com", password: "123456")
student2 = User.create!(email: "vak@gmail.com", password: "123456")
student3 = User.create!(email: "john@gmail.com", password: "123456")
student4 = User.create!(email: "mary@gmail.com", password: "123456")

profile1 = Profile.create(first_name: "exam", last_name: "ple", user: student1)
profile2 = Profile.create(first_name: "v", last_name: "vak", user: student2)
profile3 = Profile.create(first_name: "john", last_name: "C", user: student3)
profile4 = Profile.create(first_name: "mary", last_name: "B", user: student4)

match1 = Match.create(pairing: { "2" => "4", "3" => "5"})
