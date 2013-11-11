class GroupExclude < ActiveRecord::Base
  belongs_to :group, inverse_of: :group_excludes
  # attr_accessible :ip_range_from, :ip_range_to

  validates_presence_of :group

  def self.host_ip_list(user)
    return nil if user.role? :admin
    group_exclude_ids = user.memberships.map { |member| member.group.group_excludes.map {|ge| ge.id}.flatten }.flatten
    return nil if group_exclude_ids.blank?
    GroupExclude.find(group_exclude_ids)
  end
end
