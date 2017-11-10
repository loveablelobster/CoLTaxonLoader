#
module WebServiceHelper
    def self.clean_record(rec) # this should go to CatalogueOfLife
      rec.delete_if { |_k, v| v.kind_of?(String) && v.empty? }
      name = rec['infraspecies'] || rec['species'] || rec['name']
      extct = rec['is_extinct'] == 'true' ? true : false
      accepted = rec['name_status'] == 'accepted name' ? true : false
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
        rank: rank,
        col_status: rec['name_status'],
        colloqial: colloqial,
        is_accepted: accepted,
        is_extinct: extct
      }
    end
end
