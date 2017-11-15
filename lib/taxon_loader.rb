# frozen_string_literal: true

require 'logger'
require_relative 'taxon_authority_service/taxon_authority_service'
TA = TaxonAuthorityService::TaxonAuthority
require_relative 'ticker'
#
module TaxonLoader
  #
  class TaxonLoader
    attr_reader :authority, :db_start_taxon, :ticker

    def initialize(target, taxon, rank,
                   log: "#{Dir.pwd}/inserted_taxa.log",
                   include_extinct_taxa: false)
      @target = target
      @authority = TA.new(service: 'catalogue_of_life',
                          taxon: taxon, rank: rank)
      @db_start_taxon = @target.start_taxon(taxon, rank)
      @ticker = Ticker.new(target, rank, log)
      @include_extinct_taxa = include_extinct_taxa
    end

    def exhaustive_downstream_grab(authority_taxon = @authority.start_taxon,
                                   db_taxon = @db_start_taxon)
      authority_taxon['child_taxa'].each do |c|
        ctx = @authority.service.full_record_for(id: c['id']).first
        txn_data = WebServiceHelper.clean_record(ctx)
        next if txn_data[:is_extinct] == true && !@include_extinct_taxa
        @ticker.print(txn_data)
        next_taxon = @target.insert_child(db_taxon, txn_data, @ticker)
        txn_data[:colloqial]&.each do |cn|
          @target.insert_common_name(next_taxon, cn)
        end
        exhaustive_downstream_grab(ctx, next_taxon) if ctx['child_taxa']
      end
    end
  end
end
