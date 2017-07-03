class LongestwordController < ApplicationController
  
  ALPHABET = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
  
  def game
    @grid = generate_grid(params[:size])
    @alphabet = ALPHABET
  end


  def generate_grid(grid_size)
    grid = []
    grid_size.to_i.times { grid << ALPHABET.sample }
    grid
  end

  def unique?(letter, grid)
    if grid.include?(letter)
      grid.delete(letter)
      true
    else
      false
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    # runs the game and return detailed hash of result
    result_hash = { time: end_time - start_time }
    translation_url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=e93c157b-1378-4ec5-9e81-df5ea2f06b87&input=#{attempt}"
    translation_json = open(translation_url).read
    translation_hash = JSON.parse(translation_json)
    attempt_upcase = attempt.upcase

    if File.read('/usr/share/dict/words').upcase.split("\n").include?(attempt_upcase)
      result_hash[:translation] = translation_hash["outputs"][0]["output"]
      result_hash[:message] = "well done"
      result_hash[:score] = 10 + attempt.length + (start_time - end_time)
    else
      result_hash[:score] = 0
      result_hash[:translation] = nil
      result_hash[:message] = "not an english word"
    end
    attempt_upcase.each_char do |letter|
      if unique?(letter, grid) == false
        result_hash[:message] = "not in the grid"
        result_hash[:score] = 0
      end
    end
    result_hash
  end

  def score
    end_time = Time.now.to_i
    @result = run_game(params[:attempt], params[:grid], params[:time].to_i, end_time)
  end

  def home
  end
end
