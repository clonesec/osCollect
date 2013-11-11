class DashboardSerializer < ActiveModel::Serializer
  attributes :name

  has_many :widgets, key: :widgets_attributes

  # self.root = false
end
