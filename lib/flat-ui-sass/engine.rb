module FlatUI
  module Rails
    class Engine < ::Rails::Engine
      initializer "flat-ui-sass.assets.precompile" do |app|
        if Dir.exist? File.join(::Rails.root, 'vendor', 'assets', 'fonts', 'flat-ui-pro')
          app.config.assets.precompile << %r(flat-ui-pro/Flat-UI-Icons\.(?:eot|svg|ttf|woff)$)
        else
          app.config.assets.precompile << %r(flat-ui/Flat-UI-Icons\.(?:eot|svg|ttf|woff)$)
        end
      end
    end
  end
end
