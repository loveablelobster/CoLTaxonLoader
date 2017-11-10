#
module TaxonLoader
  #
  class TaxonLoader
    attr_reader :service, :root_taxon
    def initialize(target, root_name, root_rank)
      @target = target
      @service = CatalogueOfLife.new
      rank = @target.taxonomy.ranks_dataset[Name: root_rank]
      @root_taxon = @target.taxonomy.taxa_dataset.where(rank: rank,
                                                        Name: root_name
                                                        ).first
      @col_start_taxon = @service.full_record_for(name: root_name,
                                                  rank: root_rank).first
    end

    def clean_record(rec) # this should go to CatalogueOfLife
      rec.delete_if { |_k, v| v.kind_of?(String) && v.empty? }
      name = rec['infraspecies'] || rec['species'] || rec['name']
      extct = rec['is_extinct'] == 'true' ? true : false # Sequel should accept true/false
      accepted = rec['name_status'] == 'accepted name' ? true : false # Sequel should accept true/false
      rank = rec['rank'] == 'Infraspecies' ? 'Subspecies' : rec['rank']
      colloqial = nil
      if rec['common_names']
        colloqial = rec['common_names'].map do |cn|
          lang = case cn['language']
          when 'English'
            'en'
          when 'Danish'
            'da'
          when 'French'
            'fr'
          when 'Portuguese'
            'pt'
          when 'Spanish'
            'es'
          else
            nil
          end
          { name: cn['name'], lang: lang }
        end
      end
      {
        tx_sr_number: rec['id'],
        name: name,
        full_name: rec['name'],
        author: rec['author'],
        rank: @target.taxonomy.rank(rank),
        col_status: rec['name_status'],
        colloqial: colloqial,
        is_accepted: accepted,
        is_extinct: extct
      }
    end

    def exhaustive_downstream_grab(crnt_col = @col_start_taxon, sp_txn = @root_taxon)
      crnt_col['child_taxa'].each do |c|
        ctx = @service.full_record_for(id: c['id']).first
        txn_data = clean_record ctx
        next if txn_data[:is_extinct] == true
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
          parent: sp_txn,
          RankID: txn_data[:rank].RankID,
          rank: txn_data[:rank],
          taxonomy: @target.taxonomy
        )
        if txn_data[:colloqial]
          txn_data[:colloqial].each do |cn|
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
