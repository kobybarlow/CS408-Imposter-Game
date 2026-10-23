sample_categories = {
  "Food" => {
    description: "Different foods",
    words: [ "Pizza", "Tacos", "Sushi", "Pancakes", "Spaghetti" ]
  },
  "Sports" => {
    description: "Sports and activities",
    words: [ "Basketball", "Soccer", "Baseball", "Tennis", "Swimming" ]
  },
  "Movies" => {
    description: "Popular movies",
    words: [ "Toy Story", "Shrek", "Finding Nemo", "Frozen", "The Lion King" ]
  }
}

sample_categories.each do |name, details|
  category = Category.find_or_create_by!(name: name) do |record|
    record.description = details[:description]
  end

  details[:words].each do |word_text|
    category.words.find_or_create_by!(word: word_text)
  end
end
