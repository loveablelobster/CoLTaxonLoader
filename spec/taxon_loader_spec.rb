require_relative '../lib/target'
require_relative '../lib/taxon_loader'

#
module TaxonLoader
  RSpec.describe 'X' do
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
  	context 'y' do
  		it 'z' do
        expect(taxon_loader.target.agent[:LastName]).to eq('Doe')
  		end
  	end
  end
end
