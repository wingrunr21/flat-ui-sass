require "bundler/gem_tasks"

namespace :flat_ui do
  desc "Converts Flat UI from LESS to SASS and vendors it"
  task :convert do |t, args|
    require 'tasks/converter'
    Converter.new.process_flat_ui!
  end

  desc "Updates the Flat UI Free submodule"
  task :update do
    `git submodule foreach git pull origin master`
  end
end
