class RingBuffer < Array
  def initialize
  end
 
  def <<(el)
    if self.size < 1000
      # ((60/5 * 24) * 3) = 3 days of history = about 1000
      super
    else
      self.shift
      self.push(el)
    end
  end
  alias :push :<<

  def self.dump(history)
    Rails.logger.info "dump: history(#{history.class})=#{history.inspect}"
    Marshal::dump(history)
  end
 
  def self.load(history)
    Rails.logger.info "load: history(#{history.class})=#{history.inspect}"
    Marshal::load(history)
  end
end
