User.destroy_all

admin = User.create(email: "admin@gmail.com", password: "123456", admin: true)
student1 = User.create(email: "example@gmail.com", password: "123456")
student2 = User.create(email: "vak@gmail.com", password: "123456")
