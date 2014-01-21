class Converter
  module FlatUIJsConversion
    def process_flat_ui_javascript_assets!
      log_status 'Processing javascripts...'
      save_to = @dest_path[:js]
      read_files('js', flat_ui_js_files).each do |name, file|
        save_file("#{save_to}/#{name}", file)
      end
      log_processed "#{flat_ui_js_files * ' '}"

      log_status 'Updating javascript manifest'
      content = ''
      flat_ui_js_files.each do |name|
        name = name.gsub(/\.js$/, '')
        content << "//= require #{@output_dir}/#{name}\n"
      end
      manifest = File.expand_path(File.join(@dest_path[:js], '..', "#{@output_dir}.js"))
      save_file(manifest, content)
      log_processed manifest
    end

    def flat_ui_js_files
      @flat_ui_js_files ||= Dir.chdir "#{@src_path}/js" do
        Dir['flatui-*.js']
      end
    end
  end
end
