#!/usr/bin/ruby -v
# encoding: utf-8
require 'securerandom'
require_relative 'unspecific/lib/service/service'
require_relative 'unspecific/lib/target/spptarget'

class Stopwatch
  def initialize()
    @start = Time.now
  end

  def elapsed_time
    now = Time.now
    elapsed = now - @start
    puts 'Started: ' + @start.to_s
    puts 'Now: ' + now.to_s
    puts 'Elapsed time: ' +  elapsed.to_s + ' seconds'
    elapsed.to_s
  end
end

s = Stopwatch.new

config = Psych.load_file('dbconfig_production.yml')

TARGET = SPPTarget::SpecifyTarget.new(config)
TAXONOMY = TARGET.collection.discipline.taxonomy
COL = Service::CatalogueOfLife.new
puts TARGET
# def clean_record(rec)
#   rec.delete_if { |_k, v| v.empty? }
#   name = rec['infraspecies'] || rec['species'] || rec['name']
#   extct = rec['is_extinct'] == 'true' ? "\x01" : "\x00"
#   accepted = rec['name_status'] == 'accepted name' ? "\x01" : "\x00"
#   rank = rec['rank'] == 'Infraspecies' ? 'Subspecies' : rec['rank']
#   colloqial = nil
#   if rec['common_names']
#     colloqial = rec['common_names'].map do |cn|
#     	lang = case cn['language']
#     	when 'English'
#     		'en'
#     	when 'Danish'
#     	  'da'
#     	when 'French'
#     	  'fr'
#     	when 'Portuguese'
#     	  'pt'
#     	when 'Spanish'
#     	  'es'
#     	else
#     	  nil
#     	end
#     	{ name: cn['name'], lang: lang }
#     end
#   end
#   { tx_sr_number: rec['id'],
#     name: name,
#     full_name: rec['name'],
#     author: rec['author'],
#     rank: TAXONOMY.rank(rank),
#     col_status: rec['name_status'],
#     colloqial: colloqial,
#     is_accepted: accepted,
#     is_extinct: extct }
# end
#
# def exhaustive_downstream_grab(crnt_col, sp_txn)
#   crnt_col['child_taxa'].each do |c|
#   	ctx = COL.full_record_for(id: c['id']).first
#   	txn_data = clean_record ctx
#     nw_txn = sp_txn.children.create(
#       TimestampCreated: DateTime.now,
#       created_by: TARGET.script_agent,
#       TimestampModified: DateTime.now,
#       modified_by: TARGET.script_agent,
#       Version: 0,
#       Name: txn_data[:name],
#       FullName: txn_data[:full_name],
#       Author: txn_data[:author],
#       IsAccepted: txn_data[:is_accepted],
#       IsHybrid: "\00",
#       Source: 'Catalogue Of Life 2017',
#       TaxonomicSerialNumber: txn_data[:tx_sr_number],
#       GUID: SecureRandom.uuid,
#       parent: sp_txn,
#       RankID: txn_data[:rank].RankID,
#       rank: txn_data[:rank],
#       taxonomy: TAXONOMY
# #       accepted_name = lineage[r][:preferred]
#     )
#     if txn_data[:colloqial]
#       txn_data[:colloqial].each do |cn|
#         nw_txn.common_names.create(
#           TimestampCreated: DateTime.now,
#           created_by: TARGET.script_agent,
#           TimestampModified: DateTime.now,
#           modified_by: TARGET.script_agent,
#           Version: 0,
#           Language: cn[:lang],
#           Name: cn[:name]
#         )
#       end
#     end
#     puts "#{txn_data[:full_name]} --> #{nw_txn}"
#   	exhaustive_downstream_grab(ctx, nw_txn) if ctx['child_taxa']
#   end
# end
#
# root = COL.full_record_for(id: '7a4d4854a73e6a4048d013af6416c253').first
#
# exhaustive_downstream_grab(root, TAXONOMY.root_taxon)
#
# puts s.elapsed_time
