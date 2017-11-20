class Match < ApplicationRecord

  def self.create_match
    all_students = User.all.reject{|user| user.admin}

    all_students_names = all_students.map{|student| student.profile.full_name}

    hash = {}

    array = all_students_names

    while array.length>0
      random_key = array[rand(array.length-1)]
      hash[array[-1]] = random_key
      array.reject!{|el| el == random_key}
      array.pop
    end

    if Match.last.created_at.min == Time.now.min
      Match.last.destroy
      Match.create(pairing: hash)
    else
      Match.create(pairing: hash)
    end
  end

end
