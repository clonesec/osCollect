class AddSearchResultsPageSizeToUser < ActiveRecord::Migration
  def change
    add_column :users, :search_results_page_size, :integer
    add_column :users, :search_id, :integer
  end
end
