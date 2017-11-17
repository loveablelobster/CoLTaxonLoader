# frozen_string_literal: true

# all_ranks: a sorted array of strings (names of taxonomic ranks)
# start_rank: a string, the name of the first (highest) rank used
class Ticker
  attr_reader :new_taxon_count

  def initialize(all_ranks, start_rank = nil, log = nil)
    start_index = start_rank ? all_ranks.index(start_rank.capitalize) : 0
    used_ranks = all_ranks[start_index..-1]
    @new_taxon_count = used_ranks.map { |r| [r, 0] }.to_h
    @indents = used_ranks.map { |r| [r, used_ranks.index(r)] }.to_h
    @logger = log ? Logger.new(log) : nil
  end

  def count(taxon_name, rank)
    new_taxon_count[rank] += 1
    @logger&.info("#{rank}: #{taxon_name}")
  end

  def indent(rank)
    s = +''
    @indents[rank].times { s << '  ' }
    s
  end

  def print(taxon_name, rank)
    puts "#{indent(rank)}#{rank}: #{taxon_name}"
  end
end
