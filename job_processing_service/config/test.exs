import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :job_processing_service, JobProcessingServiceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8NIJeZMZ7z1OIK6iIGCPni5/Fh6DAsg5cW1JSgkUUg7+SJCpU7B56Q6lgKQZg6VS",
  server: false

# In test we don't send emails.
config :job_processing_service, JobProcessingService.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
