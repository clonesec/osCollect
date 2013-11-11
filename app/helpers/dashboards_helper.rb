module DashboardsHelper
  include ActionView::Helpers::UrlHelper

  def set_dashboardJSON(widget_title, widget_id, widget_content_selector, chart_id)
    "\tvar widget = {" +
    "widgetTitle : \"#{truncate(widget_title, length: 40)}<a href='/charts/#{chart_id}' title='Edit' style='float:right; text-decoration:none'><i class='icon-edit' style='font-size:15px'></i> </a>\", " +
    "widgetId : \"#{widget_id}\", " +
    "widgetContent : $(\"##{widget_content_selector}\")" +
    "};\n" +
    "\tdashboardJSON.push(widget);\n"
  end
end
