require 'active_resource'

ActiveResource::HttpMock.reset!

ActiveResource::HttpMock.respond_to do |mock|
  valid_user = {
    user: {
      email: 'tester@test.com'
    }
  }

  valid_session = { auth_token: '12345' }.merge!(valid_user)

  #----------------------------------------------------------------------------
  # For Sessions
  #----------------------------------------------------------------------------
  mock.post '/core/sessions.json',
    { 'Content-Type' => 'application/json' },
    valid_session.to_json,
    201

  mock.get "#{Agrian::Sites.for_service(:core)[:test].first.uri}/users/current",
    { 'Accept' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
    valid_user.to_json,
    200

  #----------------------------------------------------------------------------
  # GFFP lists
  #----------------------------------------------------------------------------
  valid_growers = {
    growers: [
      {
        id: SecureRandom.uuid,
        name: 'Grower Guy',
        code: 'GUY'
      }, {
        id: SecureRandom.uuid,
        name: 'Grower Gal',
        code: 'LADY'
      }
    ]
  }

  valid_farms = {
    farms: [
      {
        id: SecureRandom.uuid,
        name: 'Grower Guy Farm 1',
        code: 'Farm 1'
      }, {
        id: SecureRandom.uuid,
        name: 'Grower Gal Berries',
        code: 'Berries'
      }
    ]
  }

  valid_fields = {
    fields: [
      {
        id: SecureRandom.uuid,
        name: 'Farmy Field',
        code: 'Field 1'
      }, {
        id: SecureRandom.uuid,
        name: 'Berry Berries',
        code: 'BB'
      }
    ]
  }

  valid_plantings = {
    plantings: [
      {
        id: SecureRandom.uuid,
        name: 'Planting 1',
        code: 'Planting 1'
      }, {
        id: SecureRandom.uuid,
        name: 'this is where the berries are',
        code: 'Berry Action'
      }
    ]
  }

  mock.get '/core/growers.json?limit=1234567890',
    { 'Accept' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
    valid_growers.to_json,
    200

  mock.get '/core/farms.json?limit=1234567890',
    { 'Accept' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
    valid_farms.to_json,
    200

  mock.get '/core/fields.json?limit=1234567890',
    { 'Accept' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
    valid_fields.to_json,
    200

  mock.get '/core/plantings.json?limit=1234567890',
    { 'Accept' => 'application/json', 'Authorization' => 'AUTH-TOKEN 12345' },
    valid_plantings.to_json,
    200
end
