class HealthController < ApplicationController
  def show
    health_status = {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      version: Rails.application.config.version || '1.0.0',
      services: {
        database: database_status,
        redis: redis_status,
        application: 'running'
      }
    }
    
    if all_services_healthy?(health_status[:services])
      render json: health_status, status: :ok
    else
      render json: health_status, status: :service_unavailable
    end
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue StandardError => e
    Rails.logger.error "Database health check failed: #{e.message}"
    'disconnected'
  end

  def redis_status
    Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')).ping
    'connected'
  rescue StandardError => e
    Rails.logger.error "Redis health check failed: #{e.message}"
    'disconnected'
  end

  def all_services_healthy?(services)
    services.values.all? { |status| status == 'connected' || status == 'running' }
  end
end