require 'sidekiq/cron'

Sidekiq::Cron::Job.create(
  name: 'Daily TV Maze Ingestion - 90 Days',
  cron: '0 2 * * *',
  class: 'TvmazeIngestionJob'
)
