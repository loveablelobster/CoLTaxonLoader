require 'logger'
require_relative 'catalogue_of_life'
require_relative 'web_service_helper'

#
module TaxonLoader
  #
  class TaxonLoader
    attr_reader :service, :root_taxon, :new_taxon_count
    def initialize(target, root_name, root_rank)
      @target = target
      @service = CatalogueOfLife.new
      rank = @target.taxonomy.ranks_dataset[Name: root_rank]
      @sp_start_taxon = @target.taxonomy.taxa_dataset.first(rank: rank,
                                                        Name: root_name)
      @col_start_taxon = @service.full_record_for(name: root_name,
                                                  rank: root_rank).first
      @available_ranks = @target.taxonomy
                                .ranks
                                .sort { |x, y| x[:RankID] <=> y[:RankID] }
                                .map(&:Name)
      @new_taxon_count = {}
      @available_ranks.each { |r| @new_taxon_count[r] = 0 }
      @logger = Logger.new("#{Dir.pwd}/inserted_taxa.log")
    end

    def exhaustive_downstream_grab(crnt_col = @col_start_taxon, sp_txn = @sp_start_taxon)
      crnt_col['child_taxa'].each do |c|
        ctx = @service.full_record_for(id: c['id']).first
        txn_data = WebServiceHelper::clean_record(ctx)
        sp_rank = @target.taxonomy.rank(txn_data[:rank])
        next if txn_data[:is_extinct] == true

        # pretty print where we are
        indent = String.new
        @available_ranks.index(txn_data[:rank]).times { indent << '  '}
        puts "#{indent}#{txn_data[:rank]}: #{txn_data[:full_name]}"

        # find or create the new taxon in Specify
        nw_txn = sp_txn.children_dataset.first(Name: txn_data[:name], RankID: sp_rank.RankID)
        unless nw_txn
          nw_txn = sp_txn.add_child(
            TimestampCreated: DateTime.now,
            CreatedByAgentID: @target.agent.AgentID,
            TimestampModified: DateTime.now,
            ModifiedByAgentID: @target.agent.AgentID,
            Version: 0,
            Name: txn_data[:name],
            FullName: txn_data[:full_name],
            Author: txn_data[:author],
            IsAccepted: txn_data[:is_accepted],
            IsHybrid: false,
            Source: 'Catalogue Of Life 2017',
            TaxonomicSerialNumber: txn_data[:tx_sr_number],
            GUID: SecureRandom.uuid,
            RankID: sp_rank.RankID,
            rank: sp_rank,
            taxonomy: @target.taxonomy
          )
          @new_taxon_count[txn_data[:rank]] += 1
          @logger.info("#{nw_txn.rank[:Name]}: #{nw_txn[:Name]} (direct child of #{nw_txn.parent.rank[:Name]}: #{nw_txn.parent[:Name]})")
        end
        if txn_data[:colloqial]
          txn_data[:colloqial].each do |cn|
            next if nw_txn.common_names_dataset.first(Language: cn[:lang], Name: cn[:name])
            nw_txn.add_common_name(
              TimestampCreated: DateTime.now,
              CreatedByAgentID: @target.agent.AgentID,
              TimestampModified: DateTime.now,
              ModifiedByAgentID: @target.agent.AgentID,
              Version: 0,
              Language: cn[:lang],
              Name: cn[:name]
            )
          end
        end
        exhaustive_downstream_grab(ctx, nw_txn) if ctx['child_taxa']
      end
    end
  end
end
