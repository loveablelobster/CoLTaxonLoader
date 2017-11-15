#
module TaxonAuthorityService

  require_relative 'web_service_helper'

  #
  class TaxonAuthority
    attr_reader :service, :start_taxon
    def initialize(service:, taxon:, rank: nil)
      require_relative service
      @service = TaxonAuthorityService.const_get(service.split('_').map(&:capitalize).join).new
      @start_taxon = @service.full_record_for(name: taxon, rank: rank).first
    end
  end
end
