require_relative './converter'

namespace :flat_ui_pro do
  desc "Converts Flat UI Pro from LESS to SASS and vendors it"
  task :convert do |t, args|
    Converter.new(:pro, './flat-ui-pro').process_flat_ui!
  end
end
