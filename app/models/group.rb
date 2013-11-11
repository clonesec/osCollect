require 'ipaddr'

class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :group_excludes, inverse_of: :group, dependent: :destroy
  accepts_nested_attributes_for :group_excludes, allow_destroy: true

  # attr_accessible :name, :user_ids, :user_tokens, :group_excludes_attributes
  attr_reader :user_tokens

  validates :name, presence: true
  validates :user_ids, presence: {message: "at least one must be selected"}
  validate :group_exclude_ips

  after_save :change_role_to_admin_for_admins_group

  def group_is_admins?
    self.name.downcase == 'admins'
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end

  def fields_with_errors
    # see: app/views/groups/_select_chain.html.erb for usage
    errs = []
    self.errors.full_messages.each do |errmsg|
      num = /#(\d+):/.match(errmsg)
      num = num.to_s.gsub("#",'').gsub(":",'').to_i
      errs << num unless num <= 0
    end
    errs
  end

  private

  def change_role_to_admin_for_admins_group
    if self.group_is_admins?
      # the default role is 'user' so let's change it to 'admin'
      Membership.transaction do
        self.memberships.each do |member|
          member.role = 'admin'
          member.save(validate: false)
        end
      end
    end
  end

  def ip_string_to_numeric(ip_string)
    IPAddr.new(ip_string, Socket::AF_INET).to_i # just for ipv4
  rescue Exception => e
    nil
  end

  def group_exclude_ips
    self.group_excludes.each_with_index do |sf, entryx|
      unless sf.ip_range_from.blank?
        sf.ip_range_from_num = ip_string_to_numeric(sf.ip_range_from)
        add_to_group_errors(entryx, sf, "'Host IP begin' is invalid") and return if sf.ip_range_from_num.nil?
      end
      add_to_group_errors(entryx, sf, "'Host IP begin' is missing, but 'Host IP end' was entered") if sf.ip_range_to.present? && sf.ip_range_from.blank?
      unless sf.ip_range_to.blank?
        sf.ip_range_to_num = ip_string_to_numeric(sf.ip_range_to)
        add_to_group_errors(entryx, sf, "'Host IP end' is invalid") and return if sf.ip_range_to_num.nil?
        add_to_group_errors(entryx, sf, "'Host IP end' may not be less than 'Host IP begin'") if sf.ip_range_to_num < sf.ip_range_from_num
      end
      sf.ip_range_to_num = sf.ip_range_from_num if sf.ip_range_from.present? && sf.ip_range_to.blank?
      sf.delete if sf.ip_range_from.blank? && sf.ip_range_to.blank?
    end
  end

  def add_to_group_errors(x, field, errmsg)
    self.errors.add(:base, "##{x+1}: " + errmsg)
    field.save(validate: false)
  end
end
