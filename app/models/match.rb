class Match < ApplicationRecord

  def self.create_match
    all_students = User.all.reject{|user| user.admin}

    number_of_students = all_students.length

    number_of_unique_pairings = number_of_students - 1

    all_students_names = all_students.map{|student| student.profile.full_name}

    new_pairings = create_pairings(all_students_names)
# check for existing key-value pair in the last (number of unique pairings) matchings
    recent_pairings = Match.all.last(number_of_unique_pairings-1).map{|match| match.pairing}

    while has_duplicates?(recent_pairings, new_pairings)
      new_pairings = create_pairings(all_students_names)
    end
    #
    # # if Match.last.created_at.sec == Time.now.sec
    # #   Match.last.destroy
    # #   Match.create(pairing: hash)
    # # else
    byebug
      Match.create(pairing: new_pairings)
    # end
  end

  def self.create_pairings(array)
  hash = {}
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
          break
        end
      end
    end
    return duplicate
  end

  def self.sort_by_created_asc
    self.order('created_at asc')
  end
end
