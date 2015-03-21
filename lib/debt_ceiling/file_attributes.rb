class FileAttributes
  attr_reader :linecount, :path, :analysed_module, :source_code
  def initialize(_module)
    @linecount       = `wc -l #{_module.path}`.match(/\d+/)[0].to_i
    @path            = _module.path
    @analysed_module = _module
    @source_code     = File.read(_module.path)
  end
end