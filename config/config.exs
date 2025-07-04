# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :food_tracker,
  ecto_repos: [FoodTracker.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :food_tracker, FoodTrackerWeb.Endpoint,
  url: [host: "munchmetrics.vossihub.org"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FoodTrackerWeb.ErrorHTML, json: FoodTrackerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FoodTracker.PubSub,
  live_view: [signing_salt: "ri/eHHZM"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :food_tracker, FoodTracker.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  food_tracker: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  food_tracker: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Gemini API
config :food_tracker, :gemini_api,
  url: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
  # Will be overridden by environment-specific config
  api_key: System.get_env("GEMINI_API_KEY") || nil

# Configure Ollama API
# config :food_tracker, :ollama_api, base_url: "http://100.93.118.103:11434/api"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
