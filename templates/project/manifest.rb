require 'bootstrap-sass'

description 'Flat UI for SASS'

assets = "../../vendor/assets"

flatui_dir = File.exist?("#{assets}/stylesheets/flat-ui-pro") ? 'flat-ui-pro' : 'flat-ui'

# Imports for Flat UI and bootstrap
stylesheet 'styles.scss'

# SCSS:
flatui_stylesheets = "#{assets}/stylesheets/#{flatui_dir}"
stylesheet '_variables.scss.erb', :to => '_variables.scss', :erb => true,
           :flatui_variables_path => File.expand_path("#{flatui_stylesheets}/_variables.scss", File.dirname(__FILE__))
           
# JS:
flatui_javascripts = "#{assets}/javascripts/#{flatui_dir}"
Dir.glob File.expand_path("#{flatui_javascripts}/*.js", File.dirname(__FILE__)) do |path|
  file = File.basename(path)
  javascript "#{flatui_javascripts}/#{file}", :to => "#{flatui_dir}/#{file}"
end

# Fonts:
flatui_fonts = "#{assets}/fonts/#{flatui_dir}"
Dir.glob File.expand_path("#{flatui_fonts}/*", File.dirname(__FILE__)) do |path|
  file = File.basename(path)
  font "#{flatui_fonts}/#{file}", :to => "#{flatui_dir}/#{file}"
end

# Images:
flatui_images = "#{assets}/images/#{flatui_dir}"
Dir.glob File.expand_path("#{flatui_images}/**/*.*", File.dirname(__FILE__)) do |path|
  file = path.match(/.+\/#{flatui_dir}\/(.+)/)[1]
  image "#{flatui_images}/#{file}", :to => "#{flatui_dir}/#{file}"
end

# Copy bootstrap fonts/JS as well
bootstrap_sass_path = Gem.loaded_specs['bootstrap-sass'].full_gem_path
assets = "#{bootstrap_sass_path}/vendor/assets"

# Figure out how many dots there are to the FS root since Compass
# operates relative to this file's directory
dots = File.dirname(__FILE__).split('/').map {|s| '..'}.join('/')

# JS:
bs_javascripts = "#{dots}/#{assets}/javascripts/bootstrap"
Dir.glob "#{bs_javascripts}/*.js" do |path|
  file = File.basename(path)
  javascript path, :to => "bootstrap/#{file}"
end

bs_fonts = "#{dots}/#{assets}/fonts/bootstrap"
Dir.glob "#{bs_fonts}/*" do |path|
  file = File.basename(path)
  font path, :to => "bootstrap/#{file}"
end
