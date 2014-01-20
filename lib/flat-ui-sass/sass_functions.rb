require 'sass'

module Sass::Script::Functions
  unless defined?(:tint)
    def tint(color, percentage)
      assert_type color, :Color
      assert_type percentage, :Number
      white = Sass::Script::Color.new([255, 255, 255])
      mix(white, color, percentage)
    end
  end
end
