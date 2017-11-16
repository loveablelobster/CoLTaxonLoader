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
      Database.instance.connect(config)
      dscp = Specify::Discipline[Name: config[:discipline]]
      default_agent(dscp.division, Specify::User[Name: config[:specifyuser]])
      @taxonomy = dscp.taxonomy
      available_ranks(@taxonomy.ranks)
    end

    def insert_child(taxon, child, ticker)
      db_rank = target_rank(child.rank)
      db_child = taxon.children_dataset.first(Name: child.name, rank: db_rank )
      return db_child if db_child
      db_child = taxon.add_child(
        TimestampCreated: DateTime.now, CreatedByAgentID: @agent.AgentID,
        TimestampModified: DateTime.now, ModifiedByAgentID: @agent.AgentID,
        Version: 0, Name: child.name, FullName: child.full_name,
        Author: child.author, IsAccepted: child.accepted?,
        IsHybrid: false, Source: 'Catalogue Of Life 2017',
        TaxonomicSerialNumber: child.identifier,
        GUID: SecureRandom.uuid, RankID: db_rank.RankID, rank: db_rank,
        taxonomy: @taxonomy
      )
      ticker.count(db_child)
      db_child
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

    def available_ranks(ranks)
      @ranks = ranks.sort { |x, y| x[:RankID] <=> y[:RankID] }.map(&:Name)
    end

    def default_agent(division, user)
      @agent = Specify::Agent.first(division: division, user: user)
    end

    def target_rank(rank)
      @taxonomy.ranks_dataset[Name: rank]
    end
  end
end
