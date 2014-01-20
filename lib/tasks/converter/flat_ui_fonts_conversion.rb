class Converter
  module FlatUIFontsConversion
    def process_flat_ui_font_assets!
      log_status 'Processing fonts...'
      files   = read_files('fonts', flat_ui_font_files)
      save_to = @dest_path[:fonts]
      files.each do |name, content|
        save_file "#{save_to}/#{name}", content
      end
    end

    def flat_ui_font_files
      @flat_ui_font_files ||= Dir.chdir "#{@src_path}/fonts" do
        Dir['*.{eot,svg,ttf,woff}'].reject{|f| f =~ /\.dev/}
      end
    end
  end
end
