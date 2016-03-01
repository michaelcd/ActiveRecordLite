require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Card < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Card)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Card.table_name).to eq('cards')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class List < SQLObject
          self.table_name = 'lists'
        end

        expect(List.table_name).to eq('lists')

        Object.send(:remove_const, :List)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Card.columns).to eq([:id, :title, :list_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Card.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        card_attributes = {title: 'SQL'}
        c = Card.new
        c.instance_variable_set('@attributes', card_attributes)

        expect(c.attributes).to equal(card_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Card.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Card < SQLObject
        self.finalize!
      end

      class List < SQLObject
        self.table_name = 'lists'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Card)
      Object.send(:remove_const, :List)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Card.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :title).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :list_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Card.new
        c.title = "HTML"
        c.id = 209
        c.list_id = 2
        expect(c.title).to eq 'HTML'
        expect(c.id).to eq 209
        expect(c.list_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        c = Card.new
        c.instance_variable_set(:@attributes, {title: "HTML"})
        expect(c.title).to eq 'HTML'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Card.new
        c.title = "HTML"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@title)
        expect(c.attributes[:title]).to eq 'HTML'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        # We have to set method expectations on the cat object *before*
        # #initialize gets called, so we use ::allocate to create a
        # blank Card object first and then call #initialize manually.
        c = Card.allocate

        expect(c).to receive(:title=).with('Canvas')
        expect(c).to receive(:id=).with(100)
        expect(c).to receive(:list_id=).with(4)

        c.send(:initialize, {title: 'Canvas', id: 100, list_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Card.new(favorite_band: 'Anybody but The Eagles')
        end.to raise_error "unknown attribute 'favorite_band'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        cards = Card.all
        expect(cards.count).to eq(7)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { title: 'cat1', list_id: 1 },
          { title: 'cat2', list_id: 2 }
        ]

        cards = Card.parse_all(hashes)
        expect(cards.length).to eq(2)
        hashes.each_index do |i|
          expect(cards[i].title).to eq(hashes[i][:title])
          expect(cards[i].list_id).to eq(hashes[i][:list_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        cards = Card.all
        cards.each { |card| expect(card).to be_instance_of(Card) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        c = Card.find(1)

        expect(c).to be_instance_of(Card)
        expect(c.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Card.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        card = Card.new(id: 123, title: 'card1', list_id: 1)

        expect(card.attribute_values).to eq([123, 'card1', 1])
      end
    end

    describe '#insert' do
      let(:card) { Card.new(title: 'SQL', list_id: 1) }

      before(:each) { card.insert }

      it 'inserts a new record' do
        expect(Card.all.count).to eq(8)
      end

      it 'sets the id once the new record is saved' do
        expect(card.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the card again
        card2 = Card.find(card.id)

        expect(card2.title).to eq('SQL')
        expect(card2.list_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        list = List.find(2)

        list.title = 'CSS'
        list.update

        # pull the list again
        list = List.find(2)
        expect(list.title).to eq('CSS')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        list = List.new
        expect(list).to receive(:insert)
        list.save
      end

      it 'calls #update when record already exists' do
        list = List.find(1)
        expect(list).to receive(:update)
        list.save
      end
    end
  end
end
