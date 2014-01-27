class TireMock

  def initialize(params)
    @entity_name = params[:entity_name].to_s
    @entity = params[:entity]
  end

  def perform_mock
    body = send "tire_response_body_for_#{@entity_name}"
    response = tire_mock_response body, 200
    Tire::HTTP::Client::RestClient.expects(:get).returns(response)
  end

  def perform_stub
    body = send "tire_response_body_for_#{@entity_name}"
    response = tire_mock_response body, 200
    Tire::HTTP::Client::RestClient.stubs(:get).returns(response)
  end

  private

  def tire_mock_response(body, code=200, headers={})
    Tire::HTTP::Response.new(body, code, headers)
  end

  def tire_response_body_for_issue
    {
        'took' => 20,
        'timed_out' => false,
        '_shards' => {
            'total' => 40,
            'successful' => 40,
            'failed' => 0
        },
        'hits' => {
            'total' => 1,
            'max_score' => 1,
            'hits' => [{
                           '_index' => @entity.index_name,
                           '_type' => @entity_name,
                           '_id' => @entity.id.to_s,
                           '_score' => 1,
                           '_source' => {
                               'id' => @entity.id,
                               'event_date' => @entity.event_date.to_s,
                               'event_datetime' => @entity.event_datetime.to_s,
                               'event_title' => @entity.event_title
                           }
                       }]
        },
        'facets' => {
            'types' => {
                '_type' => 'terms',
                'missing' => 0,
                'total' => 1,
                'other' => 0,
                'terms' => [{
                                'term' => @entity_name,
                                'count' => 1
                            }]
            }
        }
    }.to_json
  end

end
