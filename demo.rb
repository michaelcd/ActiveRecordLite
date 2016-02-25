require_relative './active_record_lite'

DBConnection::reset

class Board < SQLObject
  has_many :lists, foreign_key: :board_id
  # has_many_through :cards, through: :lists, source: :cards
  finalize!
end

class List < SQLObject
  belongs_to :board, foreign_key: :board_id
  has_many :cards, foreign_key: :list_id
  finalize!
end

class Card < SQLObject
  belongs_to :list, foreign_key: :list_id
  has_one_through :board, :list, :board
  finalize!
end

programming_board = Board.where({title: "Programming"}).first
board_lists = programming_board.lists
# board_cards = programming_board.cards
list1_cards = board_lists.first.cards
list2_cards = board_lists.last.cards

puts "Board: #{programming_board.title}"
puts "Lists: #{board_lists.map {|list| list.title}}"
puts "Programming Cards: #{list1_cards.map {|card| card.title}}"
puts "Framework Cards: #{list2_cards.map {|card| card.title}}"
