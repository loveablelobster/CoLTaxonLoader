# frozen_string_literal: true

require_relative 'taxon'
#
module TaxonAuthorityService

  #
  class TaxonAuthority
    attr_reader :service, :start_taxon
    def initialize(service:, taxon:, rank: nil)
      require_relative service
      @service = TaxonAuthorityService.const_get(service.split('_').map(&:capitalize).join).new
      @start_taxon = Taxon.new(authority: self, taxon: taxon, rank: rank)
    end

    def to_s
      @service.to_s
    end
  end
end
