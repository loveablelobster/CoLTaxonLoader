require_relative 'catalogue_of_life'
require_relative 'web_service_helper'

#
module TaxonLoader
  #
  class TaxonLoader
    attr_reader :service, :root_taxon
    def initialize(target, root_name, root_rank)
      @target = target
      @service = CatalogueOfLife.new
      rank = @target.taxonomy.ranks_dataset[Name: root_rank]
      @sp_start_taxon = @target.taxonomy.taxa_dataset.first(rank: rank,
                                                        Name: root_name)
      @col_start_taxon = @service.full_record_for(name: root_name,
                                                  rank: root_rank).first
    end

    def exhaustive_downstream_grab(crnt_col = @col_start_taxon, sp_txn = @sp_start_taxon)
      crnt_col['child_taxa'].each do |c|
        ctx = @service.full_record_for(id: c['id']).first
        txn_data = WebServiceHelper::clean_record(ctx)
        txn_data[:rank] = @target.taxonomy.rank(txn_data[:rank])
        next if txn_data[:is_extinct] == true
        nw_txn = sp_txn.children_dataset.first(Name: txn_data[:name], RankID: txn_data[:rank].RankID) || sp_txn.add_child(
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
          RankID: txn_data[:rank].RankID,
          rank: txn_data[:rank],
          taxonomy: @target.taxonomy
        )
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
        puts "#{txn_data[:full_name]} --> #{nw_txn}"
        exhaustive_downstream_grab(ctx, nw_txn) if ctx['child_taxa']
      end
    end
  end
end
