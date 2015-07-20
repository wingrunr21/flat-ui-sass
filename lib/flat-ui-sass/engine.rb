module FlatUI
  module Rails
    class Engine < ::Rails::Engine
      initializer "flat-ui-sass.assets.precompile" do |app|
        app.config.assets.precompile << 'flat-ui/login/*.png'

        if Dir.exist? File.join(::Rails.root, 'vendor', 'assets', 'fonts', 'flat-ui-pro')
          %w(eot svg ttf woff).each do |format|
            app.config.assets.precompile << "flat-ui-pro/glyphicons/*.#{format}"
            app.config.assets.precompile << "flat-ui/lato/*.#{format}"
          end
        else
          %w(eot svg ttf woff).each do |format|
            app.config.assets.precompile << "flat-ui/glyphicons/*.#{format}"
            app.config.assets.precompile << "flat-ui/lato/*.#{format}"
          end
        end
      end
    end
  end
end
