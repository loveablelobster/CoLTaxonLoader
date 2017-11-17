require_relative '../lib/ticker'

RSpec.describe Ticker do
  let(:ticker) do
    all_ranks = ['Class', 'Order', 'Family', 'Genus', 'Species']
    Ticker.new(all_ranks, 'Family')
  end

  context 'upon initialization' do
    it 'initializes the `new_taxon_count`' do
      expect(ticker.new_taxon_count).to eq({ 'Family' => 0,
                                             'Genus' => 0,
                                             'Species' => 0 })
    end

    it 'initializes the `indent`' do
    	expect { ticker.print('Addams', 'Family') }.to output("Family: Addams\n").to_stdout
    end
  end
end
