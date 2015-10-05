puts 'Spam Filter Lab 1'

class SpamFilter

  def initialize(trainingData, testingData)
    @training_data = trainingData
    @testing_data = testingData
    @threshold = 0.22
    @prob_ham = 0
    @prob_spam = 0

    #Get the universe prob for P(h) and P(s)
    calculate_probs

    puts "Prob ham: #{@prob_ham}"
    puts "Prob spam: #{@prob_spam}"

    @length_analyzer = LengthAnalyzer.new(9)
    @upper_analyzer = Case_Analyzer.new
    @number_analyzer = Number_Analyzer.new
    @site_analyzer = Website_Analyzer.new

    train
  end

  def train
    @length_analyzer.analyze(@training_data)
    @upper_analyzer.analyze(@training_data)
    @number_analyzer.analyze(@training_data)
    @site_analyzer.analyze(@training_data)

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

  def bayes_is_spam(line)
    spam = @length_analyzer.prob_given_spam(line) * @upper_analyzer.prob_given_spam(line) * @number_analyzer.prob_given_spam(line) * @site_analyzer.prob_given_spam(line)
    spam *= @prob_spam
  end

  def bayes_is_ham(line)
    spam = @length_analyzer.prob_given_ham(line) * @upper_analyzer.prob_given_ham(line) * @number_analyzer.prob_given_ham(line) * @site_analyzer.prob_given_ham(line)
    spam *= @prob_ham
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
    @ham_num
  end

  def get_spam
    @spam_num
  end

  def print
    puts "Total ham: #{@ham_num}   Total spam: #{@spam_num}   Total: #{get_total}"
  end

end

class Money_Analyzer

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

  return dictionary

end

def numberOfWordsInDictionary(table)

  count = 0

  table.each do |x,y|
    count += y
  end

  return count

end

def pWord(x, dictionary)

  prob = dictionary[x].to_f / dictionary.size

end

def pSentence(x, dictionary)

  sentence = x.split
  prob = 0

  #Calculate probability based off each word
  sentence.each do |word|

    result = pWord(word, dictionary)

    if result == 0
      next
    end

    if prob == 0
      prob = result
    else
      prob *= result
    end
  end

  #TODO: Calculate prob based off of sentence length


  return prob;
end


texts = Array.new
trainingData = Array.new
testingData = Array.new
trainingHam = Array.new
trainingSpam = Array.new

#Read in file
file = File.new('spamcollection.txt', 'r')
while (line = file.gets)
  texts.push(line)
end
file.close

#Randomize input
texts = texts.shuffle

#Find cutoff for training data.  First 75% of our data is used for training.
trainingIndex = texts.length/4*3

#Sort into training data and testing data
texts.each_index do |index|
  if index < trainingIndex
    trainingData.push(texts[index])
  else
    testingData.push(texts[index])
  end
end

#Seperate training data into spam and ham.  Removing ham and spam from each line
trainingData.each do |data|
  if data.split.first == 'ham'
    trainingHam.push(data.split.drop(1).join(' '))
  else
    trainingSpam.push(data.split.drop(1).join(' '))
  end
end

puts "Training data size: #{trainingData.size}"
puts "Training ham size: #{trainingHam.size}"
puts "Training spam size: #{trainingSpam.size}"

hamDictionary = create_dictionary(trainingHam)
spamDictionary = create_dictionary(trainingSpam)

probHam = trainingHam.size.to_f / trainingData.size.to_f
probSpam = 1 - probHam

puts
puts "ProbHam: #{probHam}"
puts "ProbSpam: #{probSpam}"

probWordGivenHam = hamDictionary.size.to_f/numberOfWordsInDictionary(hamDictionary)
probWordGivenSpam = spamDictionary.size.to_f/numberOfWordsInDictionary(spamDictionary)

puts
puts pSentence('We have a sentence', hamDictionary)
puts pSentence('We have a sentence', spamDictionary)

puts
puts

sample = '8007 FREE for 1st week! No1 Nokia tone 4 ur mob every week just txt NOKIA to 8007 Get txting and tell ur mates www.getzed.co.uk POBox 36504 W4 5WQ norm 150p/tone 16+'

puts pSentence(sample, hamDictionary)
puts pSentence(sample, spamDictionary)

#Test data

spam_filter = SpamFilter.new(trainingData, testingData)

lengthToken = LengthAnalyzer.new(9)
lengthToken.analyze(trainingData)

puts puts
lengthToken.print


puts "Probability is spam: #{lengthToken.prob_spam(sample)}"
puts spam_filter.is_spam(sample)

spam_filter.print_truthtable

money_analyzer = Money_Analyzer.new
money_analyzer.analyze(trainingData)
money_analyzer.print

puts puts 'Uppercase'

case_analyzer = Case_Analyzer.new
case_analyzer.analyze(trainingData)
case_analyzer.print

puts puts 'Numbers'

number_analyzer = Number_Analyzer.new
number_analyzer.analyze(trainingData)
number_analyzer.print

puts puts 'Website'

website_analyzer = Website_Analyzer.new
website_analyzer.analyze(trainingData)
website_analyzer.print


puts
puts
puts
puts
puts

puts 'Truth table'
puts "Length: #{lengthToken.prob_ham(sample)}\t#{lengthToken.prob_spam(sample)}"
puts "Upper: #{case_analyzer.prob_ham(sample)}\t#{case_analyzer.prob_spam(sample)}"
puts "Numbers: #{number_analyzer.prob_ham(sample)}\t#{number_analyzer.prob_spam(sample)}"
puts "Sites: #{website_analyzer.prob_ham(sample)}\t#{website_analyzer.prob_spam(sample)}"

puts
puts
puts
puts "Length: #{lengthToken.prob_given_ham(sample)}\t#{lengthToken.prob_given_spam(sample)}"