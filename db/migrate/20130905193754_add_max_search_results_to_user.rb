class AddMaxSearchResultsToUser < ActiveRecord::Migration
  def change
    add_column :users, :max_search_results, :integer, default: 50
  end
end
