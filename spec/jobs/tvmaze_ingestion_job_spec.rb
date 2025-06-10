require 'rails_helper'

RSpec.describe TvmazeIngestionJob, type: :job do
  describe '#perform' do
    it 'processes TV show data' do
      expect { described_class.perform_now }.not_to raise_error
    end
  end
end