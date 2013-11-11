class Log < ActiveRecord::Base
  belongs_to :user

  # attr_accessible :active, :name, :description, :host_ips, :auto_run_at, :last_run, :send_email
  
  validates :active, presence: true
  validates :name, presence: true
  validates :host_ips, presence: true
  validates :auto_run_at, presence: true
end
