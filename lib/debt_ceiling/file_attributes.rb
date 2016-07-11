class FileAttributes
  attr_reader :linecount, :path, :source_code
  def initialize(file_path)
    @linecount       = `wc -l #{file_path}`.match(/\d+/)[0].to_i
    @path            = file_path
    @source_code     = File.read(file_path)
  end
end