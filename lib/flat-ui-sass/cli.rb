require 'optparse'
require 'tasks/converter'
require 'flat-ui-sass/version'

module FlatUI
  class CLI
    class << self
      def start(*args)
        options = parse_options!(*args)
        Converter.new(options[:type], options[:input], options).process_flat_ui!
      end

      private

      def parse_options!(*args)
        options = {
          type: :pro,
          input: 'flat-ui-pro',
          log_level: 1
        }

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: fui_convert [options]"
          opts.separator ""
          opts.separator "Options:"

          opts.on("--type [TYPE]", "-t", [:free, :pro], "Specify the type of conversion to perform (free or pro).","Default is pro") do |type|
            if type
              options[:type] = type.to_sym
              options[:input] = "flat-ui" if type == :free
            end
          end
          opts.on("--log_level [LEVEL]", "-l", OptionParser::DecimalInteger, "Specify the verbosity of the log output", "Default is 1. Levels are 0-3.") do |level|
            options[:log_level] = level if level
          end
          opts.on("--input [DIR]", "-i", "The Flat-UI root directory.","Default is flat-ui-pro") do |dir|
            options[:input] = dir if dir
          end
          opts.on_tail("-h", "--help", "Show help") do
            puts opts
            exit
          end
          opts.on_tail("--version", "Show version") do
            puts "Flat-UI Compatibility:"
            puts "  Free v#{FlatUI::VERSION}"
            puts "  Pro v#{FlatUI::PRO_VERSION}"
            exit
          end
        end

        opt_parser.parse!(args)
        options
      end
    end
  end
end
