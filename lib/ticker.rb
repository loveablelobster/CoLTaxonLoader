# frozen_string_literal: true

#
class Ticker
  attr_reader :new_taxon_count

  def initialize(target, rank, log = nil)
    @new_taxon_count = target.ranks.map { |r| [r, 0] }.to_h

    # set the indent for console log
    start_index = target.ranks.index(rank.capitalize)
    @indents = target.ranks[start_index..-1]
                     .map { |r| [r, target.ranks.index(r)] }.to_h

    @logger = log ? Logger.new(log) : nil
  end

  def count(taxon)
    new_taxon_count[taxon.rank[:Name]] += 1
    @logger&.info("#{taxon.rank[:Name]}: #{taxon[:FullName]}")
  end

  def indent(rank)
    s = +''
    @indents[rank].times { s << '  ' }
    s
  end

  def print(taxon)
    puts "#{indent(taxon[:rank])}#{taxon[:rank]}: #{taxon[:full_name]}"
  end
end
