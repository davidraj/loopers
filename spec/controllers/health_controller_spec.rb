require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe 'GET #index' do
    it 'returns health status' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end