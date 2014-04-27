# Rails view helpers for Flat-UI glyphs
# Based on https://github.com/bokmann/font-awesome-rails/blob/master/app/helpers/font_awesome/rails/icon_helper.rb
module FlatUI
  module Rails
    module IconHelper
      # Creates an icon tag given an icon name and possible icon
      # modifiers.
      #
      # Examples
      #
      #   fui_icon "heart"
      #   # => <i class="fui-heart"></i>
      #
      #   fui_icon "heart", tag: :span
      #   # => <span class="fui-heart"></span>
      #
      #   fui_icon "heart", text: "Flat-UI!"
      #   # => <i class="fui-heart"></i> Flat-UI!
      #   fui_icon "arrow-right", text: "Get started", right: true
      #   # => Get started <i class="fui-arrow-right"></i>
      #
      #   fui_icon "photo", class: "pull-left"
      #   # => <i class="fui-photo pull-left"></i>
      #
      #   fui_icon "user", data: { id: 123 }
      #   # => <i class="fui-user" data-id="123"></i>
      #
      #   content_tag(:li, fui_icon("check", text: "Bulleted list item"))
      #   # => <li><i class="fui-check"></i> Bulleted list item</li>
      def fui_icon(names = "flag", options = {})
        classes = Private.icon_names(names)
        classes.concat Array.wrap(options.delete(:class))
        text = options.delete(:text)
        right_icon = options.delete(:right)
        tag = options.delete(:tag) { :i }
        icon = content_tag(tag, nil, options.merge(:class => classes))
        Private.icon_join(icon, text, right_icon)
      end

      module Private
        extend ActionView::Helpers::OutputSafetyHelper

        def self.icon_join(icon, text, reverse_order = false)
          return icon if text.blank?
          elements = [icon, ERB::Util.html_escape(text)]
          elements.reverse! if reverse_order
          safe_join(elements, " ")
        end

        def self.icon_names(names = [])
          array_value(names).map { |n| "fui-#{n}" }
        end

        def self.array_value(value = [])
          value.is_a?(Array) ? value : value.to_s.split(/\s+/)
        end
      end
    end
  end
end
