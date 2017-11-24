class Match < ApplicationRecord
  attr_accessor :pairings
  @@pairings
  def self.pairings
    @@pairings
  end
  
  def self.create_match(date)
    @@pairings ||= create_array_of_pairings(students_names)
    if same_day?(date)
      match = Match.find_by(pairing_date: date)
      overwrite_this_and_later_matchings(match)
    elsif match_to_be_created_is_earlier_than_others?(date)
      add_pairings(students_names) if pairings_run_out?
      create_consequent_match(date)
      overwrite_later_matches(date)
    else
      add_pairings(students_names) if pairings_run_out?
      create_consequent_match(date)
    end
  end

  def self.match_to_be_created_is_earlier_than_others?(date)
    Match.all.select{|match| match[:pairing_date]>date}.length>0
  end
  # block of methods to insert matching inbetween
  def self.collect_later_matches(date)
    Match.sort_by_pairing_date.all.select{|match| match[:pairing_date]>date}
  end

  def self.collect_later_dates(date)
    collect_later_matches(date).map{|match| match[:pairing_date]}
  end

  def self.overwrite_later_matches(date)
    later_dates = collect_later_dates(date)
    collect_later_matches(date).each {|match| match.destroy}
    later_dates.each{|date| create_consequent_match(date)}
  end
  # end of insert -block
  # block of methods for adding consequent new matches
  def self.pairings_run_out?
    @@pairings.length==number_of_robin_rounds*Match.count
  end

  def self.add_pairings(students)
    @@pairings.concat(create_array_of_pairings(students))
  end

  def self.create_consequent_match(date)
    match = Match.create(pairing_date: date)
    pairing = select_pairing(date)
    match[:pairing] = pairing
    match.save
  end

  def self.select_pairing(date)
    match = Match.find_by(pairing_date: date)
    @@pairings[match_index(match)]
  end

  def self.match_index(match)
    Match.sort_by_pairing_date.all.index(match)
  end
  #---end of creating block
  # block of methods for overwriting previously created matchings
  def self.overwrite_this_and_later_matchings(match)
    pairings_to_shuffle(match)
    matches_to_overwrite(match).each do |match|
      if match
        match[:pairing] = @@pairings[match_index(match)]
        match.save
      end
    end
  end

  def self.matches_to_overwrite(match)
    indexes_of_this_and_later_matchings(match).map do |index|
      Match.sort_by_pairing_date.all[index]
    end
  end

  def self.pairings_to_shuffle(match)
    pairings_to_shuffle_array=[]
    indexes=indexes_of_this_and_later_matchings(match)
    indexes.each do |index|
      pairings_to_shuffle_array<<@@pairings[index]
    end
    pairings_to_shuffle_array.shuffle!
    pairings_to_shuffle_array_index=0
    indexes.each do |index|
      @@pairings[index]=pairings_to_shuffle_array[pairings_to_shuffle_array_index]
      pairings_to_shuffle_array_index+=1
    end
    pairings_to_shuffle_array
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
    number_of_pairings_to_shuffle = number_of_unique_matches - index_in_the_round_robin
  end
  # ---end of overwriting -block
  # block of round robin methods
  def self.create_array_of_pairings(students)
    array_of_pairings = []
    mutated_array = mutate_array(students)
    fixed_element = mutated_array.shift()
    shuffled_array = mutated_array

    (number_of_unique_matches).times do
      array_of_pairings << do_robin_round(fixed_element, shuffled_array)
      shuffled_array.shift()
      shuffled_array.rotate!
    end
    array_of_pairings.shuffle
  end

  def self.mutate_array(array)
    first_half = array.first(array.length/2)
    last_half = array.last(array.length/2).reverse
    first_half.concat(last_half)
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
    # array=mutate_array(array)
    number = array.length
    (number/2).times do |index|
      hash[array[index]] = array[-1-index]
    end
    hash
  end
  # ---end of robin -block
  # block of helper methods
  def self.same_day?(date)
    return false unless Match.find_by(pairing_date: date)
    Match.find_by(pairing_date: date).pairing_date.day == date.day &&
    Match.find_by(pairing_date: date).pairing_date.month == date.month &&
    Match.find_by(pairing_date: date).pairing_date.year == date.year
  end

  def self.students_names
    all_students = User.all.reject{|user| user.admin}
    all_students.map{|student| student.profile.full_name}
  end

  def self.number_of_students
    students_names.length
  end
  #subblock of methods for displaying matches for students only
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
    Match.sort_by_pairing_date.all.select do |match|
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
    self.pairing[full_name] ? self.pairing[full_name] : self.pairing.key(full_name)
  end
  #----end of students -helper-block
  def self.sort_by_pairing_date
    self.order('pairing_date asc')
  end

  def nice_date
    "#{pairing_date.year}-#{pairing_date.month}-#{pairing_date.day}"
  end
  # ---end of helper-block
end
