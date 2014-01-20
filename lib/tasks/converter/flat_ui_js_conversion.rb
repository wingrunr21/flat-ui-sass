class Converter
  module FlatUIJsConversion
    def process_flat_ui_javascript_assets!

    end

    def flat_ui_js_files
      @flat_ui_js_files ||= Dir.chdir "#{@src_path}/js" do
        Dir['flatui-*.js']
      end
    end
  end
end
