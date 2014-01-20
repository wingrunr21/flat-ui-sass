# coding: utf-8
#
# Based on the conversion script used for bootstrap-sass
# https://github.com/twbs/bootstrap-sass/blob/master/tasks/converter.rb
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this work except in compliance with the License.
# You may obtain a copy of the License in the LICENSE file, or at:
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'
require 'fileutils'
require 'term/ansicolor'
require 'forwardable'

# Pull in stuff from bootstrap-sass
spec = Bundler.load.specs.find{|s| s.name == 'bootstrap-sass'}
%w{logger char_string_scanner less_conversion}.each do |file|
  require File.join(spec.full_gem_path, 'tasks', 'converter', file) 
end

require_relative 'converter/flatui_less_conversion'
require_relative 'converter/filesystem'

class Converter
  extend Forwardable
  include FileSystem
  include FlatUILessConversion

  def initialize(type = :free, src_path = './less', dest_path = {})
    @logger     = Logger.new
    @src_path = File.expand_path(src_path)
    @output_dir = type == :free ? 'flat-ui' : 'flat-ui-pro'
    @dest_path = {
      js: File.join('vendor/assets/javascripts', @output_dir),
      scss: File.join('vendor/assets/stylesheets', @output_dir),
      fonts: File.join('vendor/assets/fonts', @output_dir),
      images: File.join('vendor/assets/images', @output_dir)
    }.merge(dest_path)
  end

  def_delegators :@logger, :log, :log_status, :log_processing, :log_transform, :log_file_info, :log_processed, :log_http_get_file, :log_http_get_files, :silence_log

  def process_flat_ui_free
    log_status 'Convert Flat UI Free from LESS to SASS'
  end

  def process_flat_ui_pro
    log_status 'Convert Flat UI Pro from LESS to SASS'
    puts " input : #{@src_path}"
    puts " output:"
    puts "     js: #{@dest_path[:js]}"
    puts "   scss: #{@dest_path[:scss]}"
    puts "  fonts: #{@dest_path[:fonts]}"
    puts " images: #{@dest_path[:images]}"

    @dest_path.each { |_, v| FileUtils.mkdir_p(v) }
    FileUtils.mkdir_p("#{@dest_path[:scss]}/modules")

    process_flatui_stylesheet_assets!
  end

  def save_file(path, content, mode='w')
    File.open(path, mode) { |file| file.write(content) }
  end
end
