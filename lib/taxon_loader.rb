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

    def initialize(target, options)
      @target = target
      @authority = TA.new(service: 'catalogue_of_life',
                          taxon: options[:name], rank: options[:rank])
      @db_start_taxon = @target.start_taxon(options[:name], options[:rank])
      @ticker = Ticker.new(target.ranks, options[:rank], options[:log])
      @include_extinct_taxa = options[:include_extinct]
    end

    def exhaustive_downstream_grab(authority_taxon = @authority.start_taxon,
                                   db_taxon = @db_start_taxon)
      authority_taxon.children.each do |child|
        next if child.is_extinct && !@include_extinct_taxa
        @ticker.print(child.full_name, child.rank)
        next_taxon = @target.insert_child(db_taxon, child, @ticker)

        child.common_names&.each do |cn|
          @target.insert_common_name(next_taxon, cn)
        end
        exhaustive_downstream_grab(child, next_taxon) if child.children?
      end
    end
  end
end
