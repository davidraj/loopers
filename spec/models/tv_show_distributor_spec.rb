require 'rails_helper'

RSpec.describe TvShowDistributor, type: :model do
  describe 'associations' do
    it { should belong_to(:tv_show) }
    it { should belong_to(:distributor) }
  end

  describe 'validations' do
    it { should validate_presence_of(:region) }
    it