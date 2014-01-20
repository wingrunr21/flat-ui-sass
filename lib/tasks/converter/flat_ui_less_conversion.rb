class Converter
  module FlatUILessConversion
    include Converter::LessConversion

    # Mixins that are added by FlatUI
    FLATUI_MIXINS = %w{placeholder-height mask background-clip dropdown-arrow form-controls-corners-reset
                       label-variant navbar-vertical-align social-button-variant}

    # Mixins that FlatUI has modified
    FLATUI_OVERRIDE_MIXINS = %w{placeholder text-hide scale animation horizontal
                                vertical directional horizontal-three-colors vertical-three-colors
                                radial striped button-variant input-size form-control
                                form-control-focus}

    # This is similar to the process_stylesheet_assets
    # utilized by bootstrap-sass except it is specific to
    # flatui
    def process_flat_ui_stylesheet_assets!
      log_status 'Processing stylesheets...'
      files = read_files('less', flat_ui_less_files)

      log_status '  Converting LESS files to Scss:'
      files.each do |name, file|
        log_processing name

        # apply common conversions
        file = convert_less(file) unless name =~ /icon-font|flat-ui/

        name    = name.sub(/\.less$/, '.scss')
        base = File.basename(name)
        name.gsub!(base, "_#{base}") unless base == 'flat-ui.scss'
        path    = File.join(@dest_path[:scss], name)
        save_file(path, file)
        log_processed File.basename(path)
      end
    end

    def flat_ui_less_files
      @flat_ui_less_files ||= Dir.chdir "#{@src_path}/less" do
        Dir['**/*.less']
      end
    end
  end
end
