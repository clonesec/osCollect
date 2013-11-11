class WidgetSerializer < ActiveModel::Serializer
  attributes :position

  has_one :chart

  # self.root = false
end
