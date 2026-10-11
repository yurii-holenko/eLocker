# See https://reactonrails.com/docs/configuration/
ReactOnRails.configure do |config|
  # Bundle used for `react_component(..., prerender: true)`. Built by the server
  # config in config/rspack into `private_output_path` (see config/shakapacker.yml).
  config.server_bundle_js_file = "server-bundle.js"
  config.enforce_private_server_bundles = true

  # Components are registered explicitly in app/javascript/packs.
  config.auto_load_bundle = false
end
