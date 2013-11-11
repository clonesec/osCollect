class HostIpCount
  attr_accessor :name, :value
  
  def initialize(name, value)
    @name = name
    @value = value
  end
  
  def to_json(*a)
    {
      "name" => @name,
      "value" => @value
    }.to_json(*a)
  end
end
