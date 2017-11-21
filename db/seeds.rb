Profile.destroy_all
Match.destroy_all
User.destroy_all

admin = User.create!(email: "admin@gmail.com", password: "123456", admin: true)
student1 = User.create!(email: "example@gmail.com", password: "123456")
student2 = User.create!(email: "vak@gmail.com", password: "123456")
student3 = User.create!(email: "john@gmail.com", password: "123456")
student4 = User.create!(email: "mary@gmail.com", password: "123456")
student5 = User.create!(email: "ann@gmail.com", password: "123456")
student6 = User.create!(email: "bob@gmail.com", password: "123456")

profile1 = Profile.create(first_name: "1", last_name: "A", user: student1)
profile2 = Profile.create(first_name: "2", last_name: "B", user: student2)
profile3 = Profile.create(first_name: "3", last_name: "C", user: student3)
profile4 = Profile.create(first_name: "4", last_name: "D", user: student4)
profile5 = Profile.create(first_name: "5", last_name: "E", user: student5)
profile6 = Profile.create(first_name: "6", last_name: "F", user: student6)

# match1 = Match.create(pairing: { "2" => "4", "3" => "5"})
