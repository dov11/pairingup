class Match < ApplicationRecord

  def self.create_match(date)

    # # if Match.last.created_at.sec == Time.now.sec
    # #   Match.last.destroy
    # #   Match.create(pairing: hash)
    # # else
      Match.create(pairing: unique_pairings, pairing_date: date)
    # end
  end

  def self.unique_pairings
    new_pairings = create_pairings(students_names)
    while has_duplicates?(recent_pairings, new_pairings)
      new_pairings = create_pairings(students_names)
    end
    new_pairings
  end

  def self.students_names
    all_students = User.all.reject{|user| user.admin}
    all_students.map{|student| student.profile.full_name}
  end

  def self.recent_pairings
    number_of_students = students_names.length
    number_of_pairings = number_of_students - 1
    Match.all.last(number_of_pairings-1).map{|match| match.pairing}
  end

  def self.create_pairings(submit_array)
  hash = {}
  array = submit_array
  while array.length>0
    random_key = array[rand(array.length-1)]
    hash[array[-1]] = random_key
    array.reject!{|el| el == random_key}
    array.pop
  end
  return hash
  end

  def self.has_duplicates?(array_of_hashes, hash)
    duplicate = false

    array_of_hashes.each do |pairing|
      hash.each do |student, its_match|
        if pairing[student] == its_match
          duplicate = true
          # break
        end
      end
    end
    return duplicate
  end

  def self.sort_by_created_asc
    self.order('pairing_date asc')
  end
end
