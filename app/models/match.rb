class Match < ApplicationRecord
  @@pairings
  def self.pairings
    @@pairings
  end
  def self.create_match(date)
    @@pairings ||= create_array_of_pairings(students_names)
    if same_day?(date)
      match = Match.find_by(pairing_date: date)
      overwrite_this_and_later_matchings(match)
    else
      # Match.create(pairing: unique_pairings(date), pairing_date: date)
      add_pairings(students_names) if pairings_run_out?
      create_consequent_match(date)
    end

  end

  def self.create_consequent_match(date)
    match = Match.create(pairing_date: date)
    pairing = select_pairing(date)
    match[:pairing] = pairing
    match.save
  end

  def self.overwrite_this_and_later_matchings(match)
    shuffled_pairings=pairings_to_shuffle(match)
    pairings_to_shuffle_index=0
    matches_to_overwrite(match).each do |match|
      if match
        match[:pairing] = shuffled_pairings[pairings_to_shuffle_index]
        match.save
      end
      @@pairings[match_index(match)] = shuffled_pairings[pairings_to_shuffle_index]
      pairings_to_shuffle_index+=1
    end
  end

  def self.matches_to_overwrite(match)
    indexes_of_this_and_later_matchings(match).map do |index|
      Match.sort_by_created_asc.all[index]
    end
  end

  def self.pairings_to_shuffle(match)(match)
    pairings_to_shuffle_array=[]
    indexes_of_this_and_later_matchings(match).each do |index|
      pairings_to_shuffle_array<<@@pairings[index]
    end
    pairings_to_shuffle_array.shuffle
  end

  def self.indexes_of_this_and_later_matchings(match)
    index = match_index(match)
    indexes=[]
    number_of_pairings_to_shuffle(match).times do
      indexes << index
      index+=1
    end
    indexes
  end

  def self.number_of_pairings_to_shuffle(match)
    index_in_the_round_robin = match_index(match) % number_of_unique_matches
    number_of_pairings_to_shuffle = 5 - index_in_the_round_robin
  end

  def self.pairings_run_out?
    @@pairings.length==number_of_robin_rounds*Match.count
  end

  # def self.unique_pairings(date)
  #   new_pairings = create_pairings(students_names)
  #   while has_duplicates?(recent_pairings(date), new_pairings)
  #     new_pairings = create_pairings(students_names)
  #   end
  #   new_pairings
  # end
  #creaing random pairings
  # def self.create_pairings(submit_array)
  #   hash = {}
  #   array = submit_array
  #   while array.length>0
  #     random_key = array[rand(array.length-1)]
  #     hash[array[-1]] = random_key
  #     array.reject!{|el| el == random_key}
  #     array.pop
  #   end
  #   return hash
  # end

  def self.create_array_of_pairings(students)
    array_of_pairings = []
    # number_of_unique_matches = number_of_students-1

    fixed_element = students[0]
    shuffled_array = students.last(number_of_students-1)

    (number_of_unique_matches).times do
      array_of_pairings << do_robin_round(fixed_element, shuffled_array)
      shuffled_array.shift()
      shuffled_array.rotate!
    end
    array_of_pairings.shuffle
  end

  def self.add_pairings(students)
    @@pairings.concat(create_array_of_pairings(students))
  end

  def self.match_index(match)
    Match.sort_by_created_asc.all.index(match)
  end

  def self.select_pairing(date)
    match = Match.find_by(pairing_date: date)
    @@pairings[match_index(match)]
  end


  def self.number_of_robin_rounds
    ((Match.all.length).to_f / (number_of_unique_matches)).ceil
  end

  def self.number_of_unique_matches
    number_of_students - 1
  end

  def self.do_robin_round(fixed_element, shuffled_array)
    round_array = shuffled_array.unshift(fixed_element)
    add_round_to_hash(round_array)
  end

  def self.add_round_to_hash(array)
    hash={}
    number = array.length
    (number/2).times do |index|
      hash[array[index]] = array[index+number/2]
    end
    hash
  end


  # def self.has_duplicates?(array_of_hashes, hash)
  #   duplicate = false
  #
  #   array_of_hashes.each do |pairing|
  #     hash.each do |student, its_match|
  #       if pairing[student] == its_match
  #         duplicate = true
  #       end
  #     end
  #   end
  #   return duplicate
  # end

  # def self.recent_pairings(date)
  #   number_of_students = students_names.length
  #   number_of_pairings = number_of_students - 1
  #   # if Match.count != 0
  #     # byebug
  #     return earlier_matchings(date).last(number_of_pairings-1).map{|match| match.pairing}
  #   # else
  #     # return []
  #   # end
  # end
  # --end create random pairings block

  def self.same_day?(date)
    return false unless Match.find_by(pairing_date: date)
    Match.find_by(pairing_date: date).pairing_date.day == date.day &&
    Match.find_by(pairing_date: date).pairing_date.month == date.month &&
    Match.find_by(pairing_date: date).pairing_date.year == date.year
  end

  # def self.this_and_later_matchings(date)
  #   Match.all.select{|match| match.pairing_date>=date}
  # end
  #
  # def self.earlier_matchings(date)
  #   Match.all.select{|match| match.pairing_date<date}
  # end
  #
  # def self.matchings_dates(matchings)
  #   matchings.map{|match| match.pairing_date}.sort
  # end
  #
  # def self.overwrite_this_and_later_matchings(date)
  #   matchings_dates = matchings_dates(this_and_later_matchings(date))
  #   this_and_later_matchings(date).each do |match|
  #     match.destroy
  #   end
  #   matchings_dates.each do |match_date|
  #     Match.create(pairing: unique_pairings(match_date), pairing_date: match_date)
  #   end
  # end


  def self.students_names
    all_students = User.all.reject{|user| user.admin}
    all_students.map{|student| student.profile.full_name}
  end

  def self.number_of_students
    students_names.length
  end




  def self.show_my_matches(user)
    Match.exclude_future_pairings.map do |match|
      match.select_my_pairings(user)
    end
  end

  def select_my_pairings(user)
    self.pairing = pairing.select{|student, its_match| student == user.profile.full_name || its_match == user.profile.full_name}
    return self
  end

  def self.exclude_future_pairings
    Match.sort_by_created_asc.all.select do |match|
      match.pairing_date<=DateTime.new(Time.now.year, Time.now.month, Time.now.day)
    end
  end

  def self.show_match_of_the_day
      matches = Match.select do |match|
        match.pairing_date==DateTime.new(Time.now.year, Time.now.month, Time.now.day)
      end
      matches[0]
  end

  def users_partner(full_name)
    self.pairing[full_name] ? self.pairing[full_name] : self.pairing.keys[0]
  end

  def self.sort_by_created_asc
    self.order('pairing_date asc')
  end

  def nice_date
    "#{pairing_date.year}-#{pairing_date.month}-#{pairing_date.day}"
  end
end
