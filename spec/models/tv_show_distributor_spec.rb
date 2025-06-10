require 'rails_helper'

RSpec.describe TvShowDistributor, type: :model do
  subject { build(:tv_show_distributor) }

  describe 'associations' do
    it { should belong_to(:tv_show) }
    it { should belong_to(:distributor) }
  end

  describe 'validations' do
    it { should validate_presence_of(:tv_show) }
    it { should validate_presence_of(:distributor) }
    it { should validate_uniqueness_of(:tv_show_id).scoped_to(:distributor_id) }
  end
end