class User < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :searches, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :charts, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :pdfs, dependent: :destroy
  has_many :logs, dependent: :destroy # really log watchers for host sending/not logs

  has_secure_password

  # attr_accessible :name, :user_ids, :user_tokens, :sentinel_ids
  # attr_accessible :username, :email, :password, :password_confirmation, :max_search_results, :search_results_page_size, :search_id, :send_weekly_log_counts

  validates :email, presence: true, 
            uniqueness: {case_sensitive: false},
            length: {minimum: 3},
            # format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
            format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  validates :username, presence: true, 
            uniqueness: {case_sensitive: false},
            length: {minimum: 3}
  validates :password, presence: true, length: {minimum: 6}, on: :create
  validates :password, presence: true, length: {minimum: 6}, on: :update, :if => :password_digest_changed?

  before_create { generate_token(:auth_token) }

  ROLES = %w[admin user]

  def roles
    self.memberships.map { |m| m.role.downcase }
  end

  def role?(has_role)
    roles.include? has_role.to_s.downcase
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    begin
      # note: don't pass complex objects like ActiveRecord models, just pass an id as a reference
      #       to the object(s) because the enqueue done by resque converts params to json:
      UserBackgroundMailer.password_reset(self.id).deliver
    rescue Exception => e
      puts "\nUserBackgroundMailer failed!\n Exception: #{e.message}\n Attempting foreground mailer...\n"
      UserMailer.password_reset(self.id).deliver
    end
  end
end
