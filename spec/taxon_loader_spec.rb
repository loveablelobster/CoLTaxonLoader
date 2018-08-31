# frozen_string_literal: true

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
      options = {
        name: 'Asaphida',
        rank: 'order',
        include_extinct: true,
        log: nil
      }
      TaxonLoader.new(Target.new(config), options)
    end

    context 'finds the starting point for the upload' do
      it 'in the database' do
        expect(taxon_loader.db_start_taxon.parent[:Name]).to eq('Trilobita')
        expect(taxon_loader.db_start_taxon.parent.rank[:Name]).to eq('Class')
      end
      it 'in the external service' do
        expect(taxon_loader.authority.start_taxon.children?).to be_truthy
      end
      it 'resets the new taxon count' do
        expect(taxon_loader.ticker.new_taxon_count).to eq('Order' => 0,
                                                          'Suborder' => 0,
                                                          'Superfamily' => 0,
                                                          'Family' => 0,
                                                          'Subfamily' => 0,
                                                          'Genus' => 0,
                                                          'Subgenus' => 0,
                                                          'Species' => 0,
                                                          'Subspecies' => 0)
      end
    end

    it 'inserts child taxa' do
      taxon_loader.load
      expect(taxon_loader.ticker.new_taxon_count).to eq('Order' => 0,
                                                        'Suborder' => 0,
                                                        'Superfamily' => 0,
                                                        'Family' => 1,
                                                        'Subfamily' => 0,
                                                        'Genus' => 1,
                                                        'Subgenus' => 0,
                                                        'Species' => 1,
                                                        'Subspecies' => 0)
    end

    after(:each) do
      clean_up = lambda do |taxon|
        taxon.children_dataset.each do |child|
          child.children? ? clean_up.call(child) : child.destroy
        end
        taxon.destroy
      end
      taxon_loader.db_start_taxon
                  .children_dataset.each { |child| clean_up.call(child) }
    end
  end
end
