require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('board')

      expect(options.foreign_key).to eq(:board_id)
      expect(options.class_name).to eq('Board')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('owner',
                                     foreign_key: :list_id,
                                     class_name: 'List',
                                     primary_key: :list_id
      )

      expect(options.foreign_key).to eq(:list_id)
      expect(options.class_name).to eq('List')
      expect(options.primary_key).to eq(:list_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('cards', 'List')

      expect(options.foreign_key).to eq(:list_id)
      expect(options.class_name).to eq('Card')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('cards', 'List',
                                   foreign_key: :owner_id,
                                   class_name: 'Card',
                                   primary_key: :list_id
      )

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Card')
      expect(options.primary_key).to eq(:list_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Card < SQLObject
        self.finalize!
      end

      class List < SQLObject
        self.table_name = 'lists'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('list')
      expect(options.model_class).to eq(List)

      options = HasManyOptions.new('cards', 'List')
      expect(options.model_class).to eq(Card)
    end

    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('list')
      expect(options.table_name).to eq('lists')

      options = HasManyOptions.new('cards', 'List')
      expect(options.table_name).to eq('cards')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Card < SQLObject
      belongs_to :list, foreign_key: :list_id

      finalize!
    end

    class List < SQLObject
      self.table_name = 'lists'

      has_many :cards, foreign_key: :list_id
      belongs_to :board

      finalize!
    end

    class Board < SQLObject
      has_many :lists

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:breakfast) { Card.find(1) }
    let(:devon) { List.find(1) }

    it 'fetches `list` from `Card` correctly' do
      expect(breakfast).to respond_to(:list)
      list = breakfast.list

      expect(list).to be_instance_of(List)
      expect(list.title).to eq('Languages')
    end

    it 'fetches `board` from `List` correctly' do
      expect(devon).to respond_to(:board)
      board = devon.board

      expect(board).to be_instance_of(Board)
      expect(board.title).to eq('Programming')
    end

    it 'returns nil if no associated object' do
      stray_card = Card.find(7)
      expect(stray_card.list).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:list2) { List.find(2) }
    let(:list2_board) { Board.find(1) }

    it 'fetches `cards` from `List`' do
      expect(list2).to respond_to(:cards)
      cards = list2.cards

      expect(cards.length).to eq(3)

      expected_card_titles = %w(jQuery React.js Ruby on Rails)
      2.times do |i|
        card = cards[i]

        expect(card).to be_instance_of(Card)
        expect(card.title).to eq(expected_card_titles[i])
      end
    end

    it 'fetches `lists` from `Board`' do
      expect(list2_board).to respond_to(:lists)
      lists = list2_board.lists

      expect(lists.length).to eq(3)
      expect(lists[0]).to be_instance_of(List)
      expect(lists[0].title).to eq('Languages')
    end

    it 'returns an empty array if no associated items' do
      cardless_list = List.find(3)
      expect(cardless_list.cards).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      card_assoc_options = Card.assoc_options
      list_options = card_assoc_options[:list]

      expect(list_options).to be_instance_of(BelongsToOptions)
      expect(list_options.foreign_key).to eq(:list_id)
      expect(list_options.class_name).to eq('List')
      expect(list_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Card.assoc_options).to have_key(:list)
      expect(List.assoc_options).to_not have_key(:list)

      expect(List.assoc_options).to have_key(:board)
      expect(Card.assoc_options).to_not have_key(:board)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Card
        has_one_through :board, :list, :board

        self.finalize!
      end
    end

    let(:card) { Card.find(1) }

    it 'adds getter method' do
      expect(card).to respond_to(:board)
    end

    it 'fetches associated `board` for a `Card`' do
      board = card.board

      expect(board).to be_instance_of(Board)
      expect(board.title).to eq('Programming')
    end
  end
end
