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
        hits: {
            total: 1,
            max_score: 1,
            hits: [
                {
                    _index: 'redmineapp_test_issues',
                    _type: @entity.class.name,
                    _id: @entity.id.to_s,
                    _score: 1,
                    _source: {
                        id: @entity.id,
                        subject: @entity.subject,
                        description: @entity.description
                    }
                }]
        }
    }.to_json
  end

end
