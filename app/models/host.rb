require 'ipaddr'

class Host < ActiveRecord::Base

  validates :host, presence: true
  validate :host_ip_string

  private

  def ip_string_to_numeric(ip_string)
    IPAddr.new(ip_string, Socket::AF_INET).to_i # just for ipv4
  rescue Exception => e
    nil
  end

  def host_ip_string
    self.host_ip = ip_string_to_numeric(self.host)
    self.errors.add('Host', "IP is invalid") and return if self.host_ip.nil?
  end
end
