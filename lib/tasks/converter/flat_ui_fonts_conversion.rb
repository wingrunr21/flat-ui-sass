# encoding: UTF-8

class Converter
  module FlatUIFontsConversion
    def process_flat_ui_font_assets!
      log_status 'Processing fonts...'
      save_to = @dest_path[:fonts]
      flat_ui_font_files.each do |file|
        FileUtils.cp "#{@src_path}/fonts/#{file}", "#{save_to}/#{file}"
      end
    end

    def flat_ui_font_files
      @flat_ui_font_files ||= Dir.chdir "#{@src_path}/fonts" do
        Dir['*.{eot,svg,ttf,woff}'].reject{|f| f =~ /\.dev/}
      end
    end
  end
end
