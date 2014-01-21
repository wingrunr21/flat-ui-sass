class Converter
  module FlatUIImageConversion
    def process_flat_ui_image_assets!
      log_status 'Processing images...'
      files   = read_files('images', flat_ui_image_files)
      save_to = @dest_path[:images]
      files.each do |name, content|
        file = "#{save_to}/#{name}"
        FileUtils.mkdir_p(File.dirname(file))
        save_file file, content
      end
    end

    def flat_ui_image_files
      @flat_ui_image_files ||= Dir.chdir "#{@src_path}/images" do
        Dir['{switch,tile,todo,icons/svg,icons/png}/**/*']
      end
    end
  end
end
