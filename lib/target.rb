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

    def start_taxon(taxon, rank)
      @taxonomy.taxa_dataset.first(rank: target_rank(rank), Name: taxon)
    end

    private

    def available_ranks(ranks)
      @ranks = ranks.sort_by { |a| a[:RankID] }.map(&:Name)
    end

    def default_agent(division, user)
      @agent = Specify::Agent.first(division: division, user: user)
    end

    # FIXME: move to Taxonomy
    def target_rank(rank)
      @taxonomy.ranks_dataset[Name: rank]
    end
  end
end
