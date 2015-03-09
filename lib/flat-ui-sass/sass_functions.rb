# Based on bootstrap-sass
# https://github.com/twbs/bootstrap-sass/blob/master/lib/bootstrap-sass/sass_functions.rb

require 'sass'

module Sass::Script::Functions
  unless Sass::Script::Functions.instance_methods.include?(:tint)
    def tint(color, percentage)
      assert_type color, :Color
      assert_type percentage, :Number
      white = Sass::Script::Color.new([255, 255, 255])
      mix(white, color, percentage)
    end
  end
  
  unless Sass::Script::Functions.instance_methods.include?(:fade)
    def fade(color, amount)
      if amount.is_a?(Sass::Script::Number) && amount.unit_str == "%"
        amount = Sass::Script::Number.new(1 - amount.value / 100.0)
      end
      fade_out(color, amount)
    end
    declare :fade, [:color, :amount]
  end

  # Based on https://github.com/edwardoriordan/sass-utilities/blob/master/lib/sass-utilities.rb
  # For Sass < 3.3.0, just echo back the variable since we can't interpolate it
  def interpolate_variable(name)
    assert_type name, :String
    ::Sass::VERSION >= '3.3.0' ? environment.var(name.value) : name
  end
  declare :interpolate_variable, [:name]
end
