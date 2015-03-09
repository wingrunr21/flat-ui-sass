require_relative 'less_conversion'

class Converter
  module FlatUILessConversion
    include Converter::LessConversion

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
        file = convert_less(file)
        file = replace_file_imports(file)
        file = cleanup_whitespace(file)

        if name.start_with?('mixins/')
          file = varargify_mixin_definitions(file, *VARARG_MIXINS)
          %w(responsive-(in)?visibility input-size text-emphasis-variant bg-variant).each do |mixin|
            file = parameterize_mixin_parent_selector file, mixin if file =~ /#{mixin}/
          end
          NESTED_MIXINS.each do |sel, name|
            file = flatten_mixins(file, sel, name) if /#{Regexp.escape(sel)}/ =~ file
          end
          file = replace_all file, /(?<=[.-])\$state/, '#{$state}' if file =~ /[.-]\$state/
        end

        case name
        when 'flat-ui.less', 'flat-ui-pro.less'
          lines = file.split "\n"
          lines.reject! {|line|
            #kill variables since those need to be manually imported before bootstrap
            line =~ /variables/
          }

          # Add a comment for the icon font
          icon_font_import = lines.index {|line| line =~ /glyphicons/}
          lines.insert(icon_font_import, "\n// Flat-UI-Icons")

          file = lines.join "\n"

          # TODO need to add configuration for the local fonts import. options are local, Google, and user
        when 'mixins/buttons.less'
          file = replace_all file, /(\.dropdown-toggle)&/, '&\1'
        when 'mixins/gradients.less'
          file = replace_ms_filters(file)
          file = deinterpolate_vararg_mixins(file)
        when 'mixins/vendor-prefixes.less'
          # remove second scale mixins as this is handled via vararg in the first one
          file = replace_rules(file, Regexp.escape('@mixin scale($ratioX, $ratioY...)')) { '' }
        when 'mixins/grid-framework.less'
          file = convert_grid_mixins file
        when 'mixins/pallets.less'
          file = replace_all file, /-(\$.+-color)/, '-#{\1}'
          file = replace_all file, /#\{\$\$\{(.+)\}\}/, 'interpolate_variable($\1)'
        when 'mixins/select.less'
          file = replace_all file, /(\$arrow-color)\)/, '\1: $inverse)'
          file = extract_nested_rule file, '.select2-container-disabled&', '.select2-container-disabled.select2-choice'
          file = parameterize_mixin_parent_selector file, 'multiple-select-variant'
        when 'mixins/switches.less'
          file = replace_all file, /\.(\$switch-name)/, '.#{\1}\2'
          file = replace_all file, /-(\$handle-name)/, '-#{\1}\2'
        when 'variables.less'
          file = insert_default_vars(file)
          file = unindent <<-SCSS + file, 12
            // a flag to toggle asset pipeline / compass integration
            // defaults to true if flat-ui-font-path function is present (no function => flat-ui-font-path('') parsed as string == right side)
            // in Sass 3.3 this can be improved with: function-exists(flatui-font-path)
            $flat-ui-sass-asset-helper: (flat-ui-font-path("") != unquote('flat-ui-font-path("")')) !default;

          SCSS
          file = replace_all file, /(\$icon-font-path:)(\s+)"..\/fonts\/(.+)\/"\s*(!default)/, '\1\2"'+@output_dir+'/\3/" \4'
          file = replace_all file, /(\$local-font-path:)(\s+)"..\/fonts\/(.+)\/"\s*(!default)/, '\1\2"'+@output_dir+'/\3/" \4'
          file = fix_variable_declaration_order file
        when 'modules/buttons.less'
          file = extract_nested_rule file, '.btn-xs&'
          file = extract_nested_rule file, '.btn-hg&'
        when 'modules/dropdowns.less'
          dropdown_menu_right = unindent extract_rule_content(file, '.dropdown-menu-right')
          dropdown_menu_left = unindent extract_rule_content(file, '.dropdown-menu-left')
          file = replace_all file, /^\s+@extend \.dropdown-menu-right;/, indent(dropdown_menu_right, 6)
          file = replace_all file, /^\s+@extend \.dropdown-menu-left;/, indent(dropdown_menu_left, 6)
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
          file = flat_ui_font_files.select{|p| File.dirname(p) =~ /glyphicons/}
                                   .map { |p| %Q(//= depend_on "#{@output_dir}/#{File.dirname(p)}/#{File.basename(p)}") } * "\n" + "\n" + file
          file = replace_rules(file, '@font-face') { |rule|
            rule = replace_all rule, /(\$icon-font(?:-\w+)+)/, '#{\1}'
            replace_asset_url rule, :font
          }
        when 'modules/local-fonts.less'
          file = flat_ui_font_files.reject{|p| File.dirname(p) =~ /glyphicons/}
                                   .map { |p| %Q(//= depend_on "#{@output_dir}/#{File.dirname(p)}/#{File.basename(p)}") } * "\n" + "\n" + file
          file = replace_rules(file, '@font-face') { |rule|
            rule = replace_all rule, /(\$local-font(?:-\w+)+)/, '#{\1}'
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
          file.gsub! /@include pallet-variant\((.+)\);/ do |match|
            match.gsub /#\{([\w\-]+)\}/, '"\1"'
          end
        when 'modules/select.less'
          file = extract_nested_rule file, '.select2-container&'
          file = apply_mixin_parent_selector(file, '\.multiselect-(?:default|primary|info|danger|success|warning|inverse)')
          file = replace_all file, '@extend .form-control all, .input-sm all;', "@extend .form-control;\n    @extend .input-sm;"
        when 'modules/switch.less'
          file = replace_all file, /\.(\$switch-name)(.*)$/, '.#{\1}\2'
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
        end

        name = name.sub(/\.less$/, '.scss')
        base = File.basename(name)
        name.gsub!(base, "_#{base}") unless base == 'flat-ui.scss' || base == 'flat-ui-pro.scss'
        path = File.join(@dest_path[:scss], name)
        save_file(path, file)
        log_processed File.basename(path)
      end

      manifest = File.join(@dest_path[:scss], '..', "#{@output_dir}.scss")
      import_string = "@import \"#{@output_dir}/flat-ui"
      import_string += "-pro" if pro?
      import_string += "\";"
      save_file(manifest, import_string)
    end

    def flat_ui_less_files
      @flat_ui_less_files ||= Dir.chdir "#{@src_path}/less" do
        Dir['**/*.less'].reject{|f| f =~ /(?:demo|docs)\.less$/ }
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

    def extract_rule_content(file, rule)
      file = file.dup
      s = CharStringScanner.new(file)
      rule_re = /(?:#{rule}[#{SELECTOR_CHAR})=(\s]*?#{RULE_OPEN_BRACE_RE})/
      rule_start_re = /^#{rule_re}/

      positions = []
      while (rule_start = s.scan_next(rule_start_re))
        pos = s.pos
        positions << (pos - rule_start.length..close_brace_pos(file, pos - 1))
      end

      content = file[positions.first]
      content.gsub!(RULE_CLOSE_BRACE_RE, '')
      content.gsub!(rule_re, '')
      content.strip!
      content
    end

    def fix_variable_declaration_order(file)
      lines = file.split("\n").push("")

      # Type needs to come after Misc variable
      # declarations
      if file.include?('Type')
        type_start = lines.index {|l| l =~ /Type/} - 1
        type_end = lines.index {|l| l =~ /Miscellaneous/} - 1

        blk = lines.slice!(type_start...type_end)
        misc_end = lines.index {|l| l =~ /^\$component-offset-horizontal/} + 1
        lines.insert(misc_end, *blk)
      end

      # Form states have to come before file input (eg after forms)
      if pro? && file.include?('== File input')
        form_states_start = lines.index {|l| l =~ /== Form states and alerts/} -1
        form_states_end = lines.index {|l| l =~ /== Tooltips/} - 1
        file_input_start = lines.index {|l| l =~ /== File input/} - 1

        blk = lines.slice!(form_states_start...form_states_end)
        lines.insert(file_input_start, *blk)
      end

      # The second Form states and alerts needs to come
      # after the Misc variables
      if pro? && file.include?('== Form states and alerts')
        type_start = lines.rindex {|l| l =~ /== Form states and alerts/} -1
        type_end = lines.index {|l| l =~ /== Miscellaneous/} - 1

        blk = lines.slice!(type_start...type_end)
        misc_end = lines.index {|l| l =~ /^\$component-offset-horizontal/} + 1
        lines.insert(misc_end, *blk)
      end

      lines.join("\n")
    end

    def fix_relative_asset_url(rule, type)
      rule = replace_all rule, /\("?\.\.?\/#{type}\/(.*?)"?\)/, "(\"#{@output_dir}/\\1\")"
      replace_all rule, /(\.\.?\/#{type}\/[\w\/\.-]+)/, "\"\\1\""
    end

    def fix_flat_ui_image_assets(file)
      file = replace_asset_url file, :image
      file = fix_relative_asset_url file, :img
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
    def load_shared
      @shared_mixins ||= begin
        log_status '  Reading shared mixins from mixins.less'
        read_mixins read_files('less', flat_ui_less_files.grep(/mixins\//)).values.join("\n"), nested: NESTED_MIXINS
      end
    end

    # @import "file.less" to "#{target_path}file;"
    def replace_file_imports(less, target_path = '')
      less.gsub %r([@\$]import ["|']([\w\-/]+)(?:.less)?["|'];),
        %Q(@import "#{target_path}\\1";)
    end

    def insert_default_vars(scss)
      log_transform
      # Make regex lazy so it doesn't break on multiple ;;
      scss.gsub(/^(\$.+?);+/, '\1 !default;')
    end

    def replace_asset_url(rule, type)
      replace_all rule, /url\((.*?)\)/, "url(if($flat-ui-sass-asset-helper, flat-ui-#{type}-path(\\1), \\1))"
    end

    # We are doing this method's job more generally
    def replace_image_urls(less)
      less
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
