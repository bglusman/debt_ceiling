#rubycritic 1.4 uses to_h method, which is not present in ruby 1.9, so until fixed
#this is needed for compatibility
class Hash
  def to_h
    to_hash
  end
end