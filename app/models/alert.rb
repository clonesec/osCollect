class Alert < ActiveRecord::Base
  belongs_to :user
  belongs_to :search
  has_many :alert_histories, dependent: :destroy

  # attr_accessible :search_id, :active, :description, :last_run, :last_status_change, :name, :status
  # attr_accessible :threshold_count, :threshold_operator, :threshold_time_seconds, :logs_in_email
  # attr_accessible :history
  
  serialize :history, RingBuffer

  validates :name, presence: true
  validates :description, presence: true
  validates :search_id, presence: true
  validates :threshold_operator, presence: true
  validates :threshold_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :threshold_time_seconds, presence: true

  def self.install_share(current_user_id, origin, alert_hash)
    alert_attributes = alert_hash.delete('alert') # remove the root key 'alert'
    search_attributes = alert_attributes.delete('search') # remove search from alert attributes
    search = Search.install_share(current_user_id, origin, search_attributes)
    alert = self.new(alert_attributes)
    alert.user_id = current_user_id
    alert.search_id = search.id
    alert.origin = origin
    alert.save(validate: false)
    alert
  end
end
