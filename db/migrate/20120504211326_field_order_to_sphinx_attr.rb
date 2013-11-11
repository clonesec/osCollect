class FieldOrderToSphinxAttr < ActiveRecord::Migration
  def change
    create_table :field_order_to_sphinx_attrs do |t|
      t.integer   :field_order
      t.string    :sphinx_attr
    end
  end
end
