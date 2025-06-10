require 'rails_helper'

RSpec.describe 'Api::V1::Analytics', type: :request do
  describe 'GET /api/v1/analytics' do
    it 'returns analytics data' do
      get '/api/v1/analytics'
      expect(response).to have_http_status(:success)
    end
  end
end