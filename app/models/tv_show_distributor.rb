class TvShowDistributor < ApplicationRecord
  belongs_to :tv_show
  belongs_to :distributor

  validates :distribution_type, inclusion: { 
    in: %w[streaming broadcast cable digital syndication],
    allow_blank: true 
  }
  validates :region, presence: true, format: { with: /\A[A-Z]{2}|global\z/ }
  validate :contract_end_after_start

  scope :active_contracts, -> { where('contract_end_date IS NULL OR contract_end_date > ?', Date.current) }
  scope :expiring_soon, ->(days = 30) { where(contract_end_date: Date.current..days.days.from_now) }
  scope :by_region, ->(region) { where(region: region) }
  scope :exclusive_deals, -> { where(exclusive: true) }

  private

  def contract_end_after_start
    return unless contract_start_date && contract_end_date
    
    if contract_end_date <= contract_start_date
      errors.add(:contract_end_date, 'must be after contract start date')
    end
  end
end