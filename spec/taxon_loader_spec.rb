require_relative '../lib/target'
require_relative '../lib/taxon_loader'

#
module TaxonLoader
  RSpec.describe TaxonLoader do
    let(:taxon_loader) do
      config = {
        adapter: 'mysql2',
        host: 'localhost',
        dbuser: 'specmaster',
        password: 'masterpass',
        database: 'SPSPEC',
        specifyuser: 'specuser',
        discipline: 'Test Discipline'
      }
    	TaxonLoader.new(Target.new(config), 'Trilobita', 'class', log: false)
    end
  	context 'finds the starting point for the upload' do
  		it 'in the database' do
        expect(taxon_loader.db_start_taxon.parent[:Name]).to eq('Arthropoda')
  		end
  		it 'in the external service' do
  			expect(taxon_loader.authority.start_taxon.children?).to be_truthy
  		end
  		it 'resets the new taxon count' do
  			expect(taxon_loader.ticker.new_taxon_count).to eq({ 'Life' => 0,
                                                            'Kingdom' => 0,
                                                            'Phylum' => 0,
                                                            'Class' => 0,
                                                            'Subclass' => 0,
                                                            'Superorder' => 0,
                                                            'Order' => 0,
                                                            'Suborder' => 0,
                                                            'Superfamily' => 0,
                                                            'Family' => 0,
                                                            'Subfamily' => 0,
                                                            'Genus' => 0,
                                                            'Subgenus' => 0,
                                                            'Species' => 0,
                                                            'Subspecies' => 0 })
  		end
  	end
  end
end
