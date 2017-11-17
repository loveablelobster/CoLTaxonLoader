require_relative '../lib/ticker'

RSpec.describe Ticker do
  let(:ticker) do
    all_ranks = ['Class', 'Order', 'Family', 'Genus', 'Species']
    Ticker.new(all_ranks)
  end

  context 'a' do
    it 'b' do
      expect(ticker.new_taxon_count).to eq({ 'Class' => 0,
                                             'Order' => 0,
                                             'Family' => 0,
                                             'Genus' => 0,
                                             'Species' => 0 })
    end
  end
end
