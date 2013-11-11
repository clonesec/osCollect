module ChartsHelper
  def set_google_visualization_arrayToDataTable(table_chart=false)
    result = []
    result << [escape_javascript(@chart.chart_title), 'count'] unless table_chart
    merge_groupby_counts = Hash.new(0)
    @all_results.group_by_results.each do |groupby_count|
      merge_groupby_counts[escape_javascript(groupby_count[1])] += groupby_count[2]
    end
    result += merge_groupby_counts.collect { |key, value| [key, value] }
    # @all_results.group_by_results.each do |groupby_count|
    #   result << [escape_javascript(groupby_count[1]), groupby_count[2]]
    # end
    count = @all_results.group_by_total
    (count <= 0) ? '[]' : raw(result)
  end
end
