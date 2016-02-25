require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Card < SQLObject
      finalize!
    end

    class List < SQLObject
      self.table_name = 'lists'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    cards = Card.where(title: 'JavaScript')
    card = cards.first

    expect(cards.length).to eq(1)
    expect(card.title).to eq('JavaScript')
  end

  it '#where can return multiple objects' do
    lists = List.where(board_id: 1)
    expect(lists.length).to eq(3)
  end

  it '#where searches with multiple criteria' do
    lists = List.where(title: 'Languages', board_id: 1)
    expect(lists.length).to eq(1)

    list = lists[0]
    expect(list.title).to eq('Languages')
    expect(list.board_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(List.where(title: 'nada')).to eq([])
  end
end
