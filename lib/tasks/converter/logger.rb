class Converter
  class Logger
    def initialize(log_level)
      @log_level = log_level || 3
    end

    def log_status(status)
      puts bold status if log_level?(:status)
    end

    def log_file_info(s)
      puts "    #{magenta s}" if log_level?(:all)
    end

    def log_transform(*args, from: caller[1][/`.*'/][1..-2].sub(/^block in /, ''))
      puts "    #{cyan from}#{cyan ": #{args * ', '}" unless args.empty?}" if log_level?(:all)
    end

    def log_processing(name)
      puts yellow "  #{File.basename(name)}" if log_level?(:processing)
    end

    def log_processed(name)
      puts green "    #{name}" if log_level?(:processing)
    end

    def puts(*args)
      STDOUT.puts *args unless log_level?(:silent)
    end
    alias log puts

    # Log levels
    #   0 is silent
    #   1 is status
    #   2 is processing
    #   3 is everything
    def log_level?(level)
      case level
      when :silent
        @log_level == 0
      when :status
        @log_level >= 1
      when :processing
        @log_level >= 2
      when :all
        @log_level >= 3
      end
    end

    # Colorize functions
    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def magenta(s); colorize(s, 35); end
    def cyan(s); colorize(s, 36); end
    def yellow(s); colorize(s, 33); end
    def green(s); colorize(s, 32); end
    def bold(s); colorize(s, 1); end
  end
end
