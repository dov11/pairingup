class Match < ApplicationRecord

  def self.create_match(date)

    if same_day?(date)
      overwrite_this_and_later_matchings(date)
    else
      Match.create(pairing: unique_pairings(date), pairing_date: date)
    end
  end

  def self.same_day?(date)
    return false unless Match.find_by(pairing_date: date)
    Match.find_by(pairing_date: date).pairing_date.day == date.day &&
    Match.find_by(pairing_date: date).pairing_date.month == date.month &&
    Match.find_by(pairing_date: date).pairing_date.year == date.year
  end

  def self.this_and_later_matchings(date)
    Match.all.select{|match| match.pairing_date>=date}
  end

  def self.earlier_matchings(date)
    Match.all.select{|match| match.pairing_date<date}
  end

  def self.matchings_dates(matchings)
    matchings.map{|match| match.pairing_date}.sort
  end

  def self.overwrite_this_and_later_matchings(date)
    matchings_dates = matchings_dates(this_and_later_matchings(date))
    this_and_later_matchings(date).each do |match|
      match.destroy
    end
    matchings_dates.each do |match_date|
      Match.create(pairing: unique_pairings(match_date), pairing_date: match_date)
    end
  end

  def self.unique_pairings(date)
    new_pairings = create_pairings(students_names)
    while has_duplicates?(recent_pairings(date), new_pairings)
      new_pairings = create_pairings(students_names)
    end
    new_pairings
  end

  def self.students_names
    all_students = User.all.reject{|user| user.admin}
    all_students.map{|student| student.profile.full_name}
  end

  def self.recent_pairings(date)
    number_of_students = students_names.length
    number_of_pairings = number_of_students - 1
    earlier_matchings(date).last(number_of_pairings-1).map{|match| match.pairing}
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
