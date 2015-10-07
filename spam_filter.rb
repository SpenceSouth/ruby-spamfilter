puts 'Spam Filter Lab 1'

class SpamFilter

  def initialize(training_data, testing_data)
    @training_data = training_data
    @testing_data = testing_data
    @threshold = 0.22
    @prob_ham = 0
    @prob_spam = 0

    #Get the universe prob for P(h) and P(s)
    calculate_probs

    @length_analyzer = LengthAnalyzer.new(9)
    @upper_analyzer = Case_Analyzer.new
    @number_analyzer = Number_Analyzer.new
    @site_analyzer = Website_Analyzer.new
    @money_analyzer = Money_Analyzer.new

    train
  end

  def train
    @length_analyzer.analyze(@training_data)
    @upper_analyzer.analyze(@training_data)
    @number_analyzer.analyze(@training_data)
    @site_analyzer.analyze(@training_data)
    @money_analyzer.analyze(@training_data)

  end

  def calculate_probs

    ham = 0
    spam = 0

    #Remove first word from training data to to see if it is spam or not
    @training_data.each do |line|
      answer = line.split.first
      text = line.split.drop(1).join(' ')

      if answer == 'ham'
        ham += 1
      elsif answer == 'spam'
        spam += 1
      else
        puts "Some error occurred... #{set}"
      end

    end

    @prob_ham = ham.to_f / @training_data.size
    @prob_spam  = spam.to_f / @training_data.size

  end

  def bayes_prob_spam_wbw(line)
    spam = @length_analyzer.prob_given_spam(line) * @upper_analyzer.prob_given_spam(line) * @site_analyzer.prob_given_spam(line) * @number_analyzer.prob_given_spam(line) * p_sentence(line, @spam_dictionary)
    spam *= @prob_spam
  end

  def bayes_prob_ham_wbw(line)
    spam = @length_analyzer.prob_given_ham(line) * @upper_analyzer.prob_given_ham(line) * @site_analyzer.prob_given_ham(line) * @number_analyzer.prob_given_ham(line) * p_sentence(line, @ham_dictionary)
    spam *= @prob_ham

  end

  def bayes_is_ham_wbw(line)
    bayes_prob_ham_wbw(line) > bayes_prob_spam_wbw(line)
  end

  def bayes_is_spam_wbw(line)
    !bayes_is_ham_wbw(line)
  end

  def bayes_truth_table_wbw

    spam_true = 0
    spam_false = 0
    ham_true = 0
    ham_false = 0

    @testing_data.each do |line|
      answer = line.split.first
      sample = line.split.drop(1).join(' ')

      if answer == 'ham'
        if bayes_is_ham_wbw(sample)
          ham_true += 1
        else
          ham_false += 1
        end
      else
        if bayes_is_spam_wbw(sample)
          spam_true += 1
        else
          spam_false += 1
        end
      end

    end

    #Print the table
    puts
    puts 'With bag of words'
    puts "\t\tHam\t\tSpam"
    puts "Ham\t\t#{ham_true}\t\t#{ham_false}"
    puts "Spam\t#{spam_false}\t\t#{spam_true}"

    puts
    puts "Correctly identifies ham #{ham_true.to_f/(ham_true + ham_false)}% of the time"
    puts "Correctly identifies spam #{spam_true.to_f/(spam_true + spam_false)}% of the time"

  end

  def bayes_prob_spam(line)
    spam = @length_analyzer.prob_given_spam(line) * @upper_analyzer.prob_given_spam(line) * @site_analyzer.prob_given_spam(line) * @number_analyzer.prob_given_spam(line)
    spam *= @prob_spam
  end

  def bayes_prob_ham(line)
    spam = @length_analyzer.prob_given_ham(line) * @upper_analyzer.prob_given_ham(line) * @site_analyzer.prob_given_ham(line) * @number_analyzer.prob_given_ham(line)
    spam *= @prob_ham

  end

  def bayes_is_ham(line)
    bayes_prob_ham(line) > bayes_prob_spam(line)
  end

  def bayes_is_spam(line)
    !bayes_is_ham(line)
  end

  def bayes_truth_table

    spam_true = 0
    spam_false = 0
    ham_true = 0
    ham_false = 0

    @testing_data.each do |line|
      answer = line.split.first
      sample = line.split.drop(1).join(' ')

      if answer == 'ham'
        if bayes_is_ham(sample)
          ham_true += 1
        else
          ham_false += 1
        end
      else
        if bayes_is_spam(sample)
          spam_true += 1
        else
          spam_false += 1
        end
      end

    end

    #Print the table
    puts
    puts 'Without bag of words'
    puts "\t\tHam\t\tSpam"
    puts "Ham\t\t#{ham_true}\t\t#{ham_false}"
    puts "Spam\t#{spam_false}\t\t#{spam_true}"

    puts
    puts "Correctly identifies ham #{ham_true.to_f/(ham_true + ham_false)} of the time"
    puts "Correctly identifies spam #{spam_true.to_f/(spam_true + spam_false)} of the time"

  end

  def add_spam_dictionary(spam_dictionary)
    @spam_dictionary = spam_dictionary
  end

  def add_ham_dictionary(ham_dictionary)
    @ham_dictionary = ham_dictionary
  end

  def set_threshold(threshold)
    if threshold <= 1
      @threshold = threshold
    else
      puts 'Can\'t set threshold greater than 100%'
    end
  end

  def analyze(line)
    @length_analyzer.prob_spam(line)
  end

  def is_spam(line)
    if analyze(line) > @threshold
      true
    else
      false
    end
  end

  def is_ham(line)
    !is_spam(line)
  end

  def print_truthtable

    spam_true = 0
    spam_false = 0
    ham_true = 0
    ham_false = 0

    @testing_data.each do |line|
      answer = line.split.first
      sample = line.split.drop(1).join(' ')

      if answer == 'ham'
        if is_ham(sample)
          ham_true += 1
        else
          ham_false += 1
        end
      else
        if is_spam(sample)
          spam_true += 1
        else
          spam_false += 1
        end
      end

    end

    #Print the table
    puts
    puts "\t\tHam\t\tSpam"
    puts "Ham\t\t#{ham_true}\t\t#{ham_false}"
    puts "Spam\t#{spam_false}\t\t#{spam_true}"

    puts
    puts "Correctly identifies ham #{ham_true.to_f/(ham_true + ham_false)}% of the time"
    puts "Correctly identifies spam #{spam_true.to_f/(spam_true + spam_false)}% of the time"

  end

  def get_optimal_threshold

    highest_average = 0.0
    highest_index = 0;
    optimal_threshold = @threshold
    temp = @threshold
    @threshold = 0.01

    98.times do

      spam_true = 0
      spam_false = 0
      ham_true = 0
      ham_false = 0

      @testing_data.each do |line|
        answer = line.split.first
        sample = line.split.drop(1).join(' ')

        if answer == 'ham'
          if is_ham(sample)
            ham_true += 1
          else
            ham_false += 1
          end
        else
          if is_spam(sample)
            spam_true += 1
          else
            spam_false += 1
          end
        end

      end

      spam_ave = spam_true.to_f / (spam_true + spam_false)
      ham_ave = ham_true.to_f / (ham_true + ham_false)

      total_ave = (spam_ave + ham_ave).to_f / 2

      #puts "Spam: #{spam_ave} Highest: #{highest_average}"

      if total_ave > highest_average
        puts "Ham: #{ham_ave} Spam: #{spam_ave} Highest: #{highest_average}"
        puts spam_true
        puts spam_false
        highest_average = total_ave
        optimal_threshold = @threshold
      end

      @threshold += 0.01

    end

    @threshold = temp
    optimal_threshold

  end

end

class Analyzer

  def initialize

    @storage = Array.new

    5.times do
      @storage.push(ProbSet.new)
    end

  end

  def print
    @storage.each do |token|
      token.print
    end
  end

  def prob_ham(line)
    @storage[token(line)].prob_ham
  end

  def prob_spam(line)
    @storage[token(line)].prob_spam
  end

  def prob_given_ham(line)
    num_x = @storage[token(line)].get_ham
    total = 0

    @storage.each do |x|
      total += x.get_ham
    end

    num_x.to_f / total.to_f

  end

  def prob_given_spam(line)
    num_x = @storage[token(line)].get_spam
    total = 0

    @storage.each do |x|
      if x.nil?
        puts 'x is nil'
      elsif x.get_spam.nil?
        puts 'x.get_spam is nil'
      end
      total += x.get_spam
    end

    num_x.to_f / total.to_f

  end

  def analyze(trainingData)

    #Remove first word from training data to to see if it is spam or not
    trainingData.each do |line|
      answer = line.split.first
      text = line.split.drop(1).join(' ')

      if answer == 'ham'
        @storage[token(text)].inc_ham
      elsif answer == 'spam'
        @storage[token(text)].inc_spam
      else
        puts "Some error occurred... #{set}"
      end

    end

  end

  def token(line)

    number_of_uppercase = line.scan(/[A-Z]/).length

    if number_of_uppercase < 10
      0
    elsif number_of_uppercase < 20
      1
    elsif number_of_uppercase < 30
      2
    elsif number_of_uppercase < 40
      3
    else
      4
    end

  end

end

class LengthAnalyzer < Analyzer

  def initialize(x)

    @storage = Array.new

    x.times do
      @storage.push(ProbSet.new)
    end

  end

  #Defines what length of text the item is
  def token(line)

    if line.length > 160
      8
    elsif line.length > 140
      7
    elsif line.length > 120
      6
    elsif line.length > 100
      5
    elsif line.length > 80
      4
    elsif line.length > 60
      3
    elsif line.length > 40
      2
    elsif line.length >= 20
      1
    elsif line.length < 20
      0
    else
      puts 'Some error occurred'
    end
  end

end

class ProbSet

  @spam_num = 0
  @ham_num = 0

  def inc_ham
    @ham_num = @ham_num.to_i + 1
  end

  def inc_spam
    @spam_num = @spam_num.to_i + 1
  end

  def get_total
    @spam_num.to_i + @ham_num.to_i
  end

  def prob_ham
    @ham_num.to_f / get_total
  end

  def prob_spam
    @spam_num.to_f / get_total
  end

  def get_ham
    @ham_num ? @ham_num : 0
  end

  def get_spam
    @spam_num ? @spam_num : 0
  end

  def print
    puts "Total ham: #{@ham_num}   Total spam: #{@spam_num}   Total: #{get_total}"
  end

end

class Money_Analyzer < Analyzer

  def print
    @storage.each do |token|
      token.print
    end
  end

  def prob_ham(line)
    @storage[money_token(line)].prob_ham
  end

  def prob_spam(line)
    @storage[money_token(line)].prob_spam
  end

  def analyze(trainingData)

    #Remove first word from training data to to see if it is spam or not
    trainingData.each do |line|
      answer = line.split.first
      text = line.split.drop(1).join(' ')

      if answer == 'ham'
        @storage[money_token(text)].inc_ham
      elsif answer == 'spam'
        @storage[money_token(text)].inc_spam
      else
        puts "Some error occurred... #{set}"
      end

    end

  end

  def money_token(line)

    number_of_symbols = line.count('$') + line.count('£')

    if number_of_symbols < 1
      0
    elsif number_of_symbols < 2
      1
    elsif number_of_symbols < 3
      2
    elsif number_of_symbols < 4
      3
    else
      4
    end

  end

end

class Case_Analyzer < Analyzer

  def token(line)

    number_of_uppercase = line.scan(/[A-Z]/).length

    if number_of_uppercase < 10
      0
    elsif number_of_uppercase < 20
      1
    elsif number_of_uppercase < 30
      2
    elsif number_of_uppercase < 40
      3
    else
      4
    end

  end

end

class Number_Analyzer < Analyzer

  def token(line)

    number_of_uppercase = line.scan(/[0-9]/).length

    if number_of_uppercase < 5
      0
    elsif number_of_uppercase < 10
      1
    elsif number_of_uppercase < 15
      2
    elsif number_of_uppercase < 20
      3
    else
      4
    end

  end
end

class Website_Analyzer < Analyzer

  def initialize

    @storage = Array.new

    2.times do
      @storage.push(ProbSet.new)
    end

  end

  def token(line)

    contains_url = line.include?('www')

    if contains_url
      0
    else
      1
    end

  end
end

def create_dictionary(data)
  dictionary = Hash.new

  #Iterate through training data
  data.each do |line|

    #Removes all symbols
    line = line.tr('^A-Za-z', ' ')

    split = line.split

    split.each do |word|
      #Check to see if word is in the hashtable... if not then add it
      if dictionary.has_key?(word.downcase)
        #puts "#{word} is already stored in the dictionary"

        #Update the value stored in the hashtable
        dictionary[word.downcase] = dictionary[word.downcase] + 1

      else
        #Place word in hash table
        dictionary[word.downcase] = 1
        #puts "Added #{word}"
      end
    end

  end

  sorted_dictionary = dictionary.sort_by {|_key, value| value}

  sorted_dictionary.each do |key, value|
    if value > 1000
      dictionary.delete(key)
    elsif value < 5
      dictionary.delete(key)
    end
  end

  puts dictionary.size

  dictionary

end

def dictionary_size(dictionary)

  count = 0

  dictionary.each do |x,y|
    count += y
  end

  count

end

def p_word_given(x, dictionary)

  if dictionary.nil?
    puts 'Dictionary is nil'
  end

  dictionary[x].to_f / dictionary_size(dictionary)

end

def p_sentence(x, dictionary)

  x = x.tr('^A-Za-z', ' ')
  sentence = x.split
  prob = -1
  sum = 0

  #Calculate probability based off each word
  sentence.each do |word|

    result = p_word_given(word.downcase, dictionary)

    if prob == -1
      prob = result
      sum += result
    else
      prob *= result
      sum += result
    end
  end

  prob
  sum.to_f / sentence.size
end


texts = Array.new
training_data = Array.new
testing_data = Array.new
training_ham = Array.new
training_spam = Array.new

#Read in file
file = File.new('spamcollection.txt', 'r')
while (line = file.gets)
  texts.push(line)
end
file.close

#Randomize input
texts = texts.shuffle

#Find cutoff for training data.  First 75% of our data is used for training.
training_index = texts.length/4*3

#Sort into training data and testing data
texts.each_index do |index|
  if index < training_index
    training_data.push(texts[index])
  else
    testing_data.push(texts[index])
  end
end

#Seperate training data into spam and ham.  Removing ham and spam from each line
training_data.each do |data|
  if data.split.first == 'ham'
    training_ham.push(data.split.drop(1).join(' '))
  else
    training_spam.push(data.split.drop(1).join(' '))
  end
end

puts "Training data size: #{training_data.size}"
puts "Training ham size: #{training_ham.size}"
puts "Training spam size: #{training_spam.size}"
puts "Testing data size: #{testing_data.size}"

ham_dictionary = create_dictionary(training_ham)
spam_dictionary = create_dictionary(training_spam)

sample = 'Hey so I got some tickets to go to the movie this friday?  Want to come?'

#Test data

spam_filter = SpamFilter.new(training_data, testing_data)
spam_filter.add_spam_dictionary(spam_dictionary)
spam_filter.add_ham_dictionary(ham_dictionary)

puts
puts 'Spam Filter:'
spam_filter.bayes_truth_table
puts
puts 'Generating with bag of words approach...'
puts
spam_filter.bayes_truth_table_wbw