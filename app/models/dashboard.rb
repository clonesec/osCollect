class Dashboard < ActiveRecord::Base
  belongs_to :user
  # has_many :widgets, inverse_of: :dashboard, dependent: :destroy, conditions: {order: "position"}
  has_many :widgets, inverse_of: :dashboard, dependent: :destroy
  accepts_nested_attributes_for :widgets, allow_destroy: true

  # attr_accessible :name, :widgets_attributes

  validates :name, presence: true
  validate :chart_was_selected

  # validate :ensure_unique_charts_per_dashboard
  # 
  # def ensure_unique_charts_per_dashboard
  #   validate_uniqueness_of_in_memory(widgets, [:chart_id], 'Dashboard can not have duplicate widgets selected.')
  # end

  def chart_was_selected
    errors.add(:base, 'Must select at least one chart') if widgets.all?(&:marked_for_destruction?)
  end

  def self.list_dashboards(user)
    dashboards = []
    user.dashboards.each do |d|
      dashboards << [d.name, d.id]
    end
    dashboards
  end

  def self.install_share(current_user_id, origin, dashboard_hash)
    ActiveRecord::Base.transaction do
      dashboard_attributes = dashboard_hash.delete('dashboard') # remove the root key 'dashboard'
      # logger.debug "dashboard_attributes(#{dashboard_attributes.class})=#{dashboard_attributes.to_yaml}\n#{'='*160}\n"
      widgets_attributes = dashboard_attributes.delete('widgets_attributes')
      logger.debug "widgets_attributes(#{widgets_attributes.class})=#{widgets_attributes.to_yaml}\n#{'='*160}\n"
      dashboard = self.new(dashboard_attributes)
      dashboard.user_id = current_user_id
      dashboard.origin = origin
      logger.debug "dashboard(#{dashboard.class})=#{dashboard.inspect}\n#{'='*160}\n"
      dashboard.save(validate: false)
      
      # for now, all widgets refer to a chart:
      widgets_attributes.each do |widget|
        logger.debug "widget(#{widget.class})=#{widget.inspect}\n#{'='*160}\n"
        chart_attrs = widget.delete('chart')
        chart = Chart.install_share(current_user_id, origin, chart_attrs)
        logger.debug "chart(#{chart.class})=#{chart.inspect}\n#{'='*160}\n"
        logger.debug "widget(#{widget.class})=#{widget.inspect}\n#{'='*160}\n"
        widget_chart = Widget.install_share(dashboard.id, chart.id, widget)
      end
      
      dashboard
      # raise ActiveRecord::Rollback
    end
  end

  private

  # Validate that the the objects in +collection+ are unique
  # when compared against all their non-blank +attrs+. If not
  # add +message+ to the base errors.
  def validate_uniqueness_of_in_memory(collection, attrs, message)
    hashes = collection.inject({}) do |hash, record|
      key = attrs.map {|a| record.send(a).to_s }.join
      if key.blank? || record.marked_for_destruction?
        key = record.object_id
      end
      hash[key] = record unless hash[key]
      hash
    end
    if collection.length > hashes.length
      self.errors.add(:base, message)
    end
  end
end
