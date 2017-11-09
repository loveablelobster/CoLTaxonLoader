require 'faraday'
require 'faraday_middleware'

# response parameter: `:json` or `:xml`
class CatalogueOfLife
  def initialize(response = :json)
    @format = response
    @conn = Faraday.new 'http://www.catalogueoflife.org/' do |conn|
      conn.response @format, content_type: /\b#{@format.to_s}$/
      conn.adapter Faraday.default_adapter
    end
  end

  # parameters
  # - *name* the name of the taxon to search for
  # - *rank* the rank of the taxon to search for;
  # optional, if ommitted, all matches within any rank will be returned;
  # can be an array to specify multiple ranks
  # - *status* the status (e.g. `accepted name`, 'synonym') of the taxon;
  # optional, if ommitted, any match satisfying the other parameters
  # will be returned
  # - *extinct* (boolean), if ommitted, any match satisfying the other
  # parameters will be returned
  # parameters *rank*, *status*, and *extinct* can be negated if prefixed
  # with *!*, e.g.
  # <tt>lookup_name('Crustacea', !'Species')</tt>
  # will return any matches for Crustacea that are not species
  # *rank* can alternatively be prefixed with *<*, *<=*, *>*, or *>=*;
  def full_record_for(id: nil, name: nil, rank: nil, extinct: nil)
    response = @conn.get do |req|
      req.url 'col/webservice?'
      req.params['format'] = @format.to_s
      req.params['response'] = 'full'
      req.params['id'] = id if id
      req.params['name'] = name if name
      req.params['rank'] = rank if rank
      req.params['extinct'] = extinct if extinct
    end
    response.body['results']
  end
end
