class Converter
  module FileSystem
    def read_files(path, files)
      contents = {}

      full_path = File.join(@src_path, path)

      if File.directory?(full_path)
        files.each do |file|
          contents[file] = File.read(File.join(full_path, file), mode: 'rb') || ''
        end
        contents
      end
    end
  end
end
