# encoding: utf-8
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
require 'forwardable'
require 'sass'

# Pull in stuff from bootstrap-sass
spec = Gem::Specification.find_by_name('bootstrap-sass')
%w{char_string_scanner less_conversion}.each do |file|
  require File.join(spec.gem_dir, 'tasks', 'converter', file)
end

require_relative 'converter/flat_ui_less_conversion'
require_relative 'converter/flat_ui_js_conversion'
require_relative 'converter/flat_ui_fonts_conversion'
require_relative 'converter/flat_ui_images_conversion'
require_relative 'converter/filesystem'
require_relative 'converter/logger'

class Converter
  extend Forwardable
  include FileSystem
  include FlatUILessConversion
  include FlatUIJsConversion
  include FlatUIFontsConversion
  include FlatUIImageConversion

  def initialize(type = :free, src_path = './flat-ui', options = {})
    @logger     = Logger.new(options[:log_level])
    @src_path = File.expand_path(src_path)
    @type = type
    @output_dir = type == :free ? 'flat-ui' : 'flat-ui-pro'
    @dest_path = {
      js: File.join('vendor/assets/javascripts', @output_dir),
      scss: File.join('vendor/assets/stylesheets', @output_dir),
      fonts: File.join('vendor/assets/fonts', @output_dir),
      images: File.join('vendor/assets/images', @output_dir)
    }
  end

  def_delegators :@logger, :log, :log_status, :log_processing, :log_transform, :log_file_info, :log_processed

  def process_flat_ui!
    log_status 'Convert Flat UI from LESS to SASS'
    log "   type: #{@output_dir}"
    log "  input: #{@src_path}"
    log " output:"
    log "     js: #{@dest_path[:js]}"
    log "   scss: #{@dest_path[:scss]}"
    log "  fonts: #{@dest_path[:fonts]}"
    log " images: #{@dest_path[:images]}"

    setup_file_structure!

    process_flat_ui_stylesheet_assets!
    process_flat_ui_javascript_assets!
    process_flat_ui_font_assets!
    process_flat_ui_image_assets!
  end

  def save_file(path, content, mode='w')
    File.open(path, mode) { |file| file.write(content) }
  end

  def free?
    !pro?
  end

  def pro?
    @type == :pro
  end

  private
  
  def setup_file_structure!
    @dest_path.each do |_, v|
      FileUtils.rm_rf(v)
      FileUtils.mkdir_p(v)
    end

    FileUtils.mkdir_p("#{@dest_path[:scss]}/modules")
  end
end
