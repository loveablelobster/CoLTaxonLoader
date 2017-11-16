# frozen_string_literal: true

require_relative 'web_service_helper'

#
module TaxonAuthorityService
  #
  class Taxon
    attr_reader :identifier, :name, :full_name, :author, :status,
                :rank, :is_extinct, :common_names, :child_ids

    def initialize(authority:, identifier: nil, taxon: nil, rank: nil)
      @authority = authority
      service = @authority.service
      load(service.get(id: identifier, name: taxon, rank: rank).first)
    end

    def accepted?
      @status == :accepted
    end

    def children
      @child_ids.map { |cid| Taxon.new(authority: @authority, identifier: cid) }
    end

    def children?
      !@child_ids.empty?
    end

    def to_s
      "<#{@authority}> #{@name} (#{@rank})"
    end

    private

    def load(record_data)
      norm_data = WebServiceHelper.normalize(record_data)
      @identifier = norm_data[:identifier]
      @name = norm_data[:name]
      @full_name = norm_data[:full_name]
      @author = norm_data[:author]
      @status = norm_data[:status]
      @rank = norm_data[:rank]
      @common_names = norm_data[:common_names]
      @is_extinct = norm_data[:is_extinct]
      @child_ids = norm_data[:child_ids]
    end
  end
end
