Match.destroy_all
User.destroy_all

admin = User.create(email: "admin@gmail.com", password: "123456", admin: true)
student1 = User.create(email: "example@gmail.com", password: "123456")
student2 = User.create(email: "vak@gmail.com", password: "123456")
student3 = User.create(email: "john@gmail.com", password: "123456")
student4 = User.create(email: "mary@gmail.com", password: "123456")

match1 = Match.create(pairing: { "2" => "4", "3" => "5"})
