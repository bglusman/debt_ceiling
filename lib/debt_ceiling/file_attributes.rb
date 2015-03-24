class FileAttributes
  attr_reader :linecount, :path, :analysed_module, :source_code
  def initialize(analysed_file)
    file_path        = analysed_file.path
    @linecount       = `wc -l #{file_path}`.match(/\d+/)[0].to_i
    @path            = file_path
    @analysed_module = analysed_file
    @source_code     = File.read(file_path)
  end
end