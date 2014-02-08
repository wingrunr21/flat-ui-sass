class Converter
  module FlatUIImageConversion
    def process_flat_ui_image_assets!
      log_status 'Processing images...'
      save_to = @dest_path[:images]
      flat_ui_image_files.each do |file|
        new_file = "#{save_to}/#{file}"
        FileUtils.mkdir_p(File.dirname(new_file))
        FileUtils.cp "#{@src_path}/images/#{file}", new_file
      end
    end

    def flat_ui_image_files
      @flat_ui_image_files ||= Dir.chdir "#{@src_path}/images" do
        Dir['{switch,tile,todo,icons,login,video}/**/*.*']
      end
    end
  end
end
