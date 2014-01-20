module FlatUI
  module Rails
    class Engine < ::Rails::Engine
      #initializer "flat-ui-sass.assets.precompile" do |app|
        #app.config.assets.precompile << %r(bootstrap/glyphicons-halflings-regular\.(?:eot|svg|ttf|woff)$)
      #end
    end

    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/flat-ui-sass.rake"
      end
    end
  end
end
