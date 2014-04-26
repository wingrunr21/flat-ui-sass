class Converter
  module FlatUILessConversion
    include Converter::LessConversion

    # Mixins that are added by FlatUI
    FLAT_UI_MIXINS = %w{placeholder-height mask background-clip dropdown-arrow form-controls-corners-reset
                       label-variant navbar-vertical-align social-button-variant}

    # Mixins that FlatUI has modified
    FLAT_UI_OVERRIDE_MIXINS = %w{placeholder text-hide scale animation horizontal
                                vertical directional horizontal-three-colors vertical-three-colors
                                radial striped button-variant input-size form-control
                                form-control-focus}

    # Modules missing from Flat UI Pro that are in Flat UI Free
    FLAT_UI_PRO_MISSING_MODULES = %w{}

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
        # icon-font bombs on this so skip it
        file = convert_less(file) unless name =~ /flat-ui|glyphicons/
        file = replace_file_imports(file)
        file = cleanup_whitespace(file)
        case name
          when 'flat-ui.less'
            lines = file.split "\n"
            lines.reject! {|line|
              #kill the fonts lines, those are up to the user
              #kill variables since those need to be manually imported before bootstrap
              line =~ /fonts|url|variables/
            }

            # Add a comment for the icon font
            icon_font_import = lines.index {|line| line =~ /glyphicons/}
            lines.insert(icon_font_import, '// Flat-UI-Icons')
            lines.delete_at(icon_font_import+2)

            file = lines.join "\n"
          when 'mixins.less'
            NESTED_MIXINS.each do |selector, prefix|
              file = flatten_mixins(file, selector, prefix)
            end
            file = varargify_mixin_definitions(file, *VARARG_MIXINS)
            file = deinterpolate_vararg_mixins(file)
            %w(responsive-(in)?visibility input-size text-emphasis-variant bg-variant).each do |mixin|
              file = parameterize_mixin_parent_selector file, mixin
            end
            file = replace_ms_filters(file)
            if pro?
              file = replace_all file, /(?<=[.-])\$state/, '#{$state}'
            else
              # calc-color mixin only exists in Flat-UI free
              file = replace_all file, /-(\$.+-color)/, '-#{\1}'
              file = replace_all file, /#\{\$\$\{(.+)\}\}/, 'interpolate_variable($\1)'
            end
            file = replace_rules(file, '  .list-group-item-') { |rule| extract_nested_rule rule, 'a&' }
            file = replace_all file, /,\s*\.open \.dropdown-toggle& \{(.*?)\}/m,
                               " {\\1}\n  .open & { &.dropdown-toggle {\\1} }"
            file = replace_all file, '$ratio, $ratio-y', '$scale-args'
            file = convert_grid_mixins file
          when 'variables.less'
            file = insert_default_vars(file)
            if ::Sass::VERSION >= '3.3.0'
              file = unindent <<-SCSS + file, 14
              // a flag to toggle asset pipeline / compass integration
              $flat-ui-sass-asset-helper: function-exists(flat-ui-font-path) !default;

              SCSS
            else
              file = unindent <<-SCSS + file, 14
              // a flag to toggle asset pipeline / compass integration
              // defaults to true if flat-ui-font-path function is present (no function => twbs-font-path('') parsed as string == right side)
              $flat-ui-sass-asset-helper: (flat-ui-font-path("") != unquote('flat-ui-font-path("")')) !default;

              SCSS
            end
            file = fix_variable_declaration_order file
            file = replace_all file, /(\$icon-font-path:\s+).*(!default)/, '\1"'+@output_dir+'/" \2'
          when 'modules/buttons.less'
            file = extract_nested_rule file, '.btn-xs&'
            file = extract_nested_rule file, '.btn-hg&'
          when 'modules/forms.less'
            # Fix mixin regex not supporting non-variable arguments
            file.gsub! /@include input-size\((?:\$.+)\);/ do |match|
              match.gsub /; /, ', '
            end
            file = apply_mixin_parent_selector(file, '\.input-(?:sm|lg|hg)')
          when 'modules/input-groups.less'
            file = replace_rules(file, '.input-group-rounded') do |rule|
              extract_and_combine_nested_rules rule
            end
          when 'modules/glyphicons.less'
            file = replace_vars(file)
            file = replace_escaping(file)
            file = replace_all file, /\#\{(url\(.*?\))}/, '\1'
            file = replace_rules(file, '@font-face') { |rule|
              rule = replace_all rule, /(\$icon-font(?:-\w+)+)/, '#{\1}'
              replace_asset_url rule, :font
            }
          when 'modules/login.less'
            file = fix_flat_ui_image_assets file
          when 'modules/navbar.less'
            # Fix mixin regex not supporting non-variable arguments
            file.gsub! /@include input-size\((?:\$.+)\);/ do |match|
              match.gsub /; /, ', '
            end
            file = apply_mixin_parent_selector(file, '\.navbar-input')
          when 'modules/palette.less'
            file.gsub! /@include calc-color\((.+)\);/ do |match|
              match.gsub /#\{([\w\-]+)\}/, '"\1"'
            end
          when 'modules/select.less'
            # Fix the include that the converter makes an extend
            file = replace_all file, /@extend \.caret/, '@include caret'
          when 'modules/spinner.less'
            # Fix mixin regex not supporting non-variable arguments
            file.gsub! /@include spinner-variant\((?:\$?.+)\);/ do |match|
              match.gsub /; /, ', '
            end
          when 'modules/switch.less'
            file = fix_flat_ui_image_assets file
          when 'modules/tile.less'
            file = fix_flat_ui_image_assets file
          when 'modules/todo.less'
            file = fix_flat_ui_image_assets file
          when 'modules/thumbnails.less'
            file = extract_nested_rule file, 'a&'
          when 'modules/type.less'
            # Since .bg-primary has a color associated with it we need to divide it into
            # two selectors
            file = replace_rules(file, '.bg-primary') do |rule|
              parts = rule.split "\n"
              selector = parts.index {|line| line =~ /\.bg-primary/}
              mixin = parts.index {|line| line =~ /@include/}
              parts.insert(mixin, "}\n#{parts[selector]}")
              rule = parts.join "\n"
            end
            file = apply_mixin_parent_selector(file, '\.(text|bg)-(success|primary|info|warning|danger)')
          when 'modules/video.less'
            file = replace_rules(file, /\s*\.vjs(?:-(?:control|time))?(?!-\w+)/) do |rule|
              selector = get_selector(rule).scan(/\.vjs(?:-(?:control|time))?(?!-\w+)/).first
              convert_arbitrary_less_ampersand(rule, selector)
            end
            file = fix_flat_ui_image_assets file
        end

        name    = name.sub(/\.less$/, '.scss')
        base = File.basename(name)
        name.gsub!(base, "_#{base}") unless base == 'flat-ui.scss'
        path    = File.join(@dest_path[:scss], name)
        save_file(path, file)
        log_processed File.basename(path)
      end

      manifest = File.join(@dest_path[:scss], '..', "#{@output_dir}.scss")
      save_file(manifest, "@import \"#{@output_dir}/flat-ui\";")
    end

    def flat_ui_less_files
      @flat_ui_less_files ||= Dir.chdir "#{@src_path}/less" do
        Dir['**/*.less'].reject{|f| f =~ /(?:demo|docs)\.less$/ }
      end
    end

    # Set load_shared to read from mixins.less again since bootstrap converted to
    # modular mixins.
    def load_shared
      @shared_mixins ||= begin
        log_status '  Reading shared mixins from mixins.less'
        read_mixins read_files('less', ['mixins.less'])['mixins.less'], nested: NESTED_MIXINS
      end
    end

    def extract_and_combine_nested_rules(file)
      matches = Hash.new {|k,v| k[v] = []}
      file = file.dup
      file.scan(/\.[\w-]+&/x) do |selector|
        #first find the rules, and remove them
        file  = replace_rules(file, "\s*#{selector}") do |rule, pos, css|
          selector = selector.gsub(/&$/, '')
          styles = rule.split(/[{}]/).last.strip
          parent = selector_for_pos(css, pos.begin).split('{').last.strip
          matches[selector] << create_rule(parent, styles)

          # Return an empty string to blank out this rule
          ""
        end
      end

      # Generate the combined nested rules
      rules = matches.inject("") do |s, (rule, children)|
        s += create_rule "&#{rule}", *children
      end
      close = close_brace_pos file, 0

      file.insert(close, indent(rules))
    end

    def create_rule(name, *styles)
      rule = "#{unindent(name)} {\n"
      styles.each {|s| rule += indent "#{s}\n"}
      rule += "}\n"
    end

    # TODO this method is on the brittle side
    # look into make it more robust
    def fix_variable_declaration_order(file)
      # Spinner needs to be moved after Buttons
      # since it depends on $btn-default-bg
      #
      # also spinner-btn-hover-bg needs to be
      # before spinner-up-btn-border
      if file.include? 'Spinner'
        lines = file.split "\n"
        spinner_start = lines.index {|l| l =~ /Spinner/}
        spinner_end = lines.index {|l| l =~ /Pagination/} - 1
        buttons_end = lines.index {|l| l =~ /Navs/} - 1

        (spinner_end - spinner_start).times do
          lines.insert(buttons_end, lines.delete_at(spinner_start))
        end

        spinner_btn_bg = lines.index {|l| l =~ /spinner-btn-bg:/}-1
        3.times do
          lines.insert(spinner_btn_bg+5, lines.delete_at(spinner_btn_bg))
        end

        file = lines.join("\n")
      end
      file
    end

    def fix_relative_asset_url(rule, type)
      # Use a really naive pluralization
      replace_all rule, /url\(['"]?\.\.\/#{type}s\/([a-zA-Z0-9\-\/\.\?#]+)['"]?\)/, "url(\"#{@output_dir}/\\1\")"
    end

    def fix_flat_ui_image_assets(file)
      file = replace_all file, /\#\{(url\(.*?\).*?)}/, '\1'
      file = fix_relative_asset_url file, :image
      file = replace_asset_url file, :image
    end

    def cleanup_whitespace(file)
      file.gsub(/\r|\t/, "")
    end

    # Based on the original convert_less_ampersand but modified
    # for flat_ui_sass
    def convert_arbitrary_less_ampersand(less, selector)
      return less unless less.include?(selector)

      styles = less.dup
      tmp = "\n"
      less.scan(/^(\s*&)(-[\w\[\]-]+\s*\{.+?})/m) do |ampersand, css|
        tmp << "#{selector}#{unindent(css)}\n"
        styles.gsub! "#{ampersand}#{css}", ""
      end

      if tmp.length > 1
        styles.gsub!(/\s*#{"\\"+selector}\s*\{\s*}/m, '')
        styles << tmp
      else
        styles = less
      end

      styles
    end

    #
    # Methods overridden from the bootstrap-sass converter
    #

    def replace_asset_url(rule, type)
      replace_all rule, /url\((.*?)\)/, "url(if($flat-ui-sass-asset-helper, flat-ui-#{type}-path(\\1), \\1))"
    end

    # @import "file" to "#{@output_dir)}/file"
    def replace_file_imports(file)
      file.gsub %r([@\$]import ["|'](.*)["|'];),
                %Q(@import "#{@output_dir}/\\1";)
    end

    # Regex will match things like spinner-input-width
    # by default.
    #
    # Fix the first lookaround to be a positive
    # lookaround and also check for word chars
    # after the word 'spin'
    def replace_spin(less)
      less.gsub(/(?<![\-$@.])spin(?![\-\w])/, 'adjust-hue')
    end

    # Fix to support replacing mixin definitions with default args
    # https://github.com/twbs/bootstrap-sass/blob/master/tasks/converter/less_conversion.rb#L293
    #
    # @mixin a() { tr& { color:white } }
    # to:
    # @mixin a($parent) { tr#{$parent} { color: white } }
    def parameterize_mixin_parent_selector(file, rule_sel)
      log_transform rule_sel
      param = '$parent'
      replace_rules(file, '^\s*@mixin\s*' + rule_sel) do |mxn_css|
        mxn_css.sub! /(?=@mixin)/, "// [converter] $parent hack\n"
        # insert param into mixin def
        mxn_css.sub!(/(@mixin [\w-]+)\(([\$\w\-:,\s]*)\)/) { "#{$1}(#{param}#{', ' if $2 && !$2.empty?}#{$2})" }
        # wrap properties in #{$parent} { ... }
        replace_properties(mxn_css) { |props|
          next props if props.strip.empty?
          spacer = ' ' * indent_width(props)
          "#{spacer}\#{#{param}} {\n#{indent(props.sub(/\s+\z/, ''), 2)}\n#{spacer}}"
        }
        # change nested& rules to nested#{$parent}
        replace_rules(mxn_css, /.*&[ ,:]/) { |rule| replace_in_selector rule, /&/, "\#{#{param}}" }
      end
    end
  end
end
