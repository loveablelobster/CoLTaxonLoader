# frozen_string_literal: true

require 'logger'
require 'securerandom'
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

    # level_depth = nil -> all available, use something like genus to limit
    def load(authority_taxon = @authority.start_taxon,
             db_taxon = @db_start_taxon)
      authority_taxon.children.each do |child|
        next if child.is_extinct && !@include_extinct_taxa
        @ticker.print(child.full_name, child.rank)
        next_taxon = find(db_taxon, child) || insert(db_taxon, child)
        common_names(child, next_taxon)
        load(child, next_taxon) if child.children?
      end
    end

    def common_names(taxon, db_taxon)
      taxon.common_names&.each do |cn|
        insert_common_name(db_taxon, cn)
      end
    end

    def find(parent, child)
      parent.children_dataset.first(Name: child.name, rank: rank(child))
    end

    def insert(parent, child)
      @ticker.count(child.full_name, child.rank)
      parent.add_child(fill_metadata(Name: child.name,
                                     FullName: child.full_name,
                                     Author: child.author,
                                     IsAccepted: child.accepted?,
                                     IsHybrid: false,
                                     Source: 'Catalogue Of Life 2017',
                                     TaxonomicSerialNumber: child.identifier,
                                     GUID: SecureRandom.uuid,
                                     RankID: rank(child).RankID,
                                     rank: rank(child),
                                     taxonomy: parent.taxonomy))
    end

    def insert_common_name(taxon, common_name_data)
      return if taxon.common_names_dataset
                     .first(Language: common_name_data[:lang],
                            Name: common_name_data[:name])
      taxon.add_common_name(fill_metadata(Language: common_name_data[:lang],
                                          Name: common_name_data[:name]))
    end

    def rank(authority_taxon)
      @target.taxonomy.rank(authority_taxon.rank)
    end

    def fill_metadata(record_data)
      {
        TimestampCreated: Time.now,
        CreatedByAgentID: @target.agent.AgentID,
        TimestampModified: Time.now,
        ModifiedByAgentID: @target.agent.AgentID,
        Version: 0
      }.merge(record_data)
    end
  end
end
