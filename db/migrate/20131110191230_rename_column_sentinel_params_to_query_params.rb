class RenameColumnSentinelParamsToQueryParams < ActiveRecord::Migration
  def change
    rename_column :searches,  :sentinel_params, :query_params
    rename_column :charts,    :sentinel_params, :query_params
  end
end
