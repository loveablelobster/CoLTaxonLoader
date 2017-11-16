# frozen_string_literal: true

require 'mysql2'
require 'sequel'
require 'singleton'

require_relative 'database'

#
module TaxonLoader
  #
  class Target
    attr_reader :agent, :taxonomy, :ranks

    def initialize(config)
      Database.instance.connect(config[:host], config[:dbuser], config[:database], config[:password])

      discipline = Specify::Discipline[Name: config[:discipline]]
      @agent = Specify::Agent.first(division: discipline.division,
                                    user: Specify::User[Name: config[:specifyuser]]
                                   )
      @taxonomy = discipline.taxonomy
      @ranks = @taxonomy.ranks.sort { |x, y| x[:RankID] <=> y[:RankID] }
                              .map(&:Name)
    end

    def insert_child(taxon, child_data, ticker)
      db_rank = target_rank(child_data[:rank])
      child = taxon.children_dataset.first(Name: child_data[:name],
                                           rank: db_rank )
      return child if child
      child = taxon.add_child(
        TimestampCreated: DateTime.now, CreatedByAgentID: @agent.AgentID,
        TimestampModified: DateTime.now, ModifiedByAgentID: @agent.AgentID,
        Version: 0, Name: child_data[:name], FullName: child_data[:full_name],
        Author: child_data[:author], IsAccepted: child_data[:is_accepted],
        IsHybrid: false, Source: 'Catalogue Of Life 2017',
        TaxonomicSerialNumber: child_data[:tx_sr_number],
        GUID: SecureRandom.uuid, RankID: db_rank.RankID, rank: db_rank,
        taxonomy: @taxonomy
      )
      ticker.count(child)
      child
    end

    def insert_common_name(taxon, common_name_data)
      return if taxon.common_names_dataset
                      .first(Language: common_name_data[:lang],
                             Name: common_name_data[:name])
      taxon.add_common_name(
        TimestampCreated: DateTime.now,
        CreatedByAgentID: @agent.AgentID,
        TimestampModified: DateTime.now,
        ModifiedByAgentID: @agent.AgentID,
        Version: 0,
        Language: common_name_data[:lang],
        Name: common_name_data[:name]
      )
    end

    def start_taxon(taxon, rank)
      @taxonomy.taxa_dataset.first(rank: target_rank(rank), Name: taxon)
    end

    private

    def target_rank(rank)
      @taxonomy.ranks_dataset[Name: rank]
    end
  end
end
