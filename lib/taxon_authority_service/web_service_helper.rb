#
module WebServiceHelper
    def self.normalize(rec) # this should go to CatalogueOfLife
      rec.delete_if { |_k, v| v.kind_of?(String) && v.empty? }
      name = rec['infraspecies'] || rec['species'] || rec['name']
      extct = rec['is_extinct'] == 'true' ? true : false
      status = rec['name_status'] == 'accepted name' ? :accepted : rec['name_status']
      rank = rec['rank'] == 'Infraspecies' ? 'Subspecies' : rec['rank']
      colloqial = nil
      if rec['common_names']
        common_names = rec['common_names'].map do |cn|
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
        identifier: rec['id'],
        name: name,
        full_name: rec['name'],
        author: rec['author'],
        rank: rank,
        status: status,
        common_names: common_names,
        is_extinct: extct,
        child_ids: rec['child_taxa'].map { |ctx| ctx['id'] }.uniq
      }
    end
end
