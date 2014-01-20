require "bundler/gem_tasks"
require 'open-uri'
require 'json'

def latest_tag
  tags = JSON.parse(open('https://api.github.com/repos/designmodo/Flat-UI/tags').read)
  tags.sort!{|a,b| b["name"] <=> a["name"]}
  tags.first
end

namespace :flat_ui do
  desc "Converts Flat UI from LESS to SASS and vendors it"
  task :convert do |t, args|
    require 'tasks/converter'
    Converter.new.process_flat_ui!
  end

  desc "Fetches and displays the latest Flat-UI tag"
  task :latest do
    tag = latest_tag
    puts "The latest Flat-UI tag is #{tag["name"]} with commit #{tag["commit"]["sha"]}"
  end

  desc "Updates the Flat UI Free submodule"
  task :update do
    `git submodule foreach git pull origin master`
  end
end
