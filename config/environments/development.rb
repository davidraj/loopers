require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  
  # Use simple file watcher instead of evented
  config.file_watcher = ActiveSupport::FileUpdateChecker
  
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Allow connections from Docker containers
  config.hosts << "backend"
  config.hosts << /.*\.docker\.internal/
  
  # For development, you can also allow all hosts (less secure)
  # config.hosts.clear
end
