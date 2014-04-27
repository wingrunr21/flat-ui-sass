# Based on bootstrap-sass.rb
# https://github.com/twbs/bootstrap-sass/blob/master/lib/bootstrap-sass.rb

require "bootstrap-sass"
require "flat-ui-sass/version"

module FlatUI
  class << self
    def load!
      require 'flat-ui-sass/sass_functions'

      register_compass_extension if compass?

      if rails?
        require 'sass-rails'
        register_rails_engine
      end

      configure_sass
    end

    # Paths
    def gem_path
      @gem_path ||= File.expand_path '..', File.dirname(__FILE__)
    end

    # This definitely needs a better solution
    def project_path
      @project_path ||= Dir.pwd
    end

    def base_path
      @base_path ||= pro? ? project_path : gem_path
    end

    def stylesheets_path
      File.join assets_path, 'stylesheets'
    end

    def fonts_path
      File.join assets_path, 'fonts'
    end

    def javascripts_path
      File.join assets_path, 'javascripts'
    end

    def images_path
      File.join assets_path, 'images'
    end

    def assets_path
      @assets_path ||= File.join base_path, 'vendor', 'assets'
    end

    # Environment detection helpers
    def asset_pipeline?
      defined?(::Sprockets)
    end

    def compass?
      defined?(::Compass)
    end

    def rails?
      defined?(::Rails)
    end

    def pro?
      Dir.exists? File.join(project_path, 'vendor/assets/stylesheets/flat-ui-pro')
    end

    private

    def configure_sass
      ::Sass.load_paths << stylesheets_path

      # bootstrap requires minimum precision of 10, see https://github.com/twbs/bootstrap-sass/issues/409
      ::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max
    end

    def register_compass_extension
      ::Compass::Frameworks.register(
          pro? ? 'flat-ui-pro' :  'flat-ui',
          :path                  => gem_path,
          :stylesheets_directory => stylesheets_path,
          :templates_directory   => File.join(gem_path, 'templates')
      )
    end

    def register_rails_engine
      require 'flat-ui-sass/engine'
    end
  end
end
FlatUi = FlatUI

FlatUI.load!
