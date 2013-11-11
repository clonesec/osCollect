class SearchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_datasources_for_select
  before_filter :get_datafieldoperators_for_select
  before_action :set_search, only: [:update, :destroy]

  def list
    @searches = current_user.searches.only_searches.where("name IS NOT NULL").order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def index
    if params[:id].blank?
      @search = Search.new
      @search.user_id = current_user.id
      @search.name = nil
    else
      @search = current_user.searches.find(params[:id])
    end
  end

  def show
    redirect_to searches_list_url
  end

  def create
    thestart = Time.now
    search_name = params[:search][:name]
    @search = Search.new(search_params)
    @search.user_id = current_user.id
    # remove single/double quotes from name which cause chart's to fail:
    @search.name = search_name.gsub(/'/, '').gsub(/"/, '') unless search_name.blank?
    if @search.valid?
      @search.save unless search_name.blank? # only save if search was named
      rows = (current_user.max_search_results.blank? || current_user.max_search_results.zero?) ? 50 : current_user.max_search_results
      @all_results = @search.perform(GroupExclude.host_ip_list(current_user), rows) if @search.errors.empty?
      # @field_counts = @search.field_counts(GroupExclude.host_ip_list(current_user))
      @field_counts = nil
      # response(Hash):
      # {"responseHeader"=>{
      #   "status"=>0, "QTime"=>1, "params"=>{"q"=>"inbound OR deny OR nt", "wt"=>"ruby"}}, 
      #   "response"=>{"numFound"=>2071207, "start"=>0,
      #     "docs"=>[
      #       {"timestamp"=>"2013-04-25T01:24:59Z", "host"=>4294967295, "program"=>"%fwsm-3-106010", 
      #         "source"=>"FIREWALL_ACCESS_DENY", 
      #         "logtext"=>"Deny inbound tcp src OUTSIDE:2.116.180.66/3116 dst INSIDE:10.0.0.0/445", 
      #         "proto_i"=>6, "srcip_l"=>41202754, "srcport_i"=>3116, "dstip_l"=>167772160, "dstport_i"=>445, 
      #         "o_int_s"=>"OUTSIDE", "i_int_s"=>"INSIDE"},
      #       ...
      #     ]
      #   }
      # }
      # @all_results["response"]["docs"].each do |doc|
      #   puts doc["logtext"]
      # end
    else
      @search.name = nil if search_name.blank?
    end
    # @search.search_fields.build if @search.search_fields.blank?
    @elapsed = Time.now - thestart
    render :index
  end

  def update
    thestart = Time.now
    @search.search_fields.each {|sf| sf.destroy }
    @search.reload
    if @search.update_attributes(search_params)
      # @all_results = @search.perform(GroupNode.allowed_list(current_user), GroupExclude.host_ip_list(current_user)) if @search.errors.empty?
      rows = (current_user.max_search_results.blank? || current_user.max_search_results.zero?) ? 50 : current_user.max_search_results
      @all_results = @search.perform(GroupExclude.host_ip_list(current_user), rows) if @search.errors.empty?
    end
    # @search.search_fields.build if @search.search_fields.blank?
    @elapsed = Time.now - thestart
    render :index
  end

  def destroy
    @search.destroy
    redirect_to searches_list_url, notice: "Deleted the search named --> \"#{@search.name}\"."
  end

  def get_fields_for_datasource
    return [] if params.blank? || params[:id].blank?
    fields = []
    dsf = DataSource.find(params[:id]).data_source_fields.select('id, name')
    dsf.each do |f|
      fields << f unless ['timestamp', 'logtext'].include?(f.name.downcase)
    end
    render json: {fields: fields}
  end

  private

  # def get_datasources_for_select
  #   ds = DataSource.order(name: :asc)
  #   @ds = []
  #   ds.each do |source|
  #     next if source.name.downcase == 'none'
  #     dsf = source.data_source_fields.select('id, name')
  #     dsf.each do |field|
  #       next if ['timestamp', 'msg'].include?(field.name.downcase)
  #       @ds = @ds << ["#{source.name} - #{field.name}", "#{source.id},#{field.id}"]
  #     end
  #   end
  #   @ds
  # end

  def get_datasources_for_select
    ds = DataSource.order(name: :asc)
    @ds = []
    ds.each do |d|
      next if d.name.downcase == 'none'
      @ds = @ds << [d.name, d.id]
    end
    @ds
  end

  def get_datafieldoperators_for_select
    dfo = DataFieldOperator.all
    @dfo = []
    dfo.each do |d|
      @dfo = @dfo << [d.operator, d.id]
    end
    @dfo
  end

  # use callbacks to share common setup or constraints between actions.
  def set_search
    @search = current_user.searches.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def search_params
    # note: search_fields_attributes are assigned id's when errors occur,
    #       so we remove them since no records are in the db for this search:
    unless params['search']['search_fields_attributes'].blank?
      params['search']['search_fields_attributes'].each { |k,v| v.delete('id') }
    end
    # remove single/double quotes from name which cause chart's to fail:
    params[:search][:name] = params[:search][:name].gsub(/'/, '').gsub(/"/, '') unless params[:search][:name].blank?
    params.require(:search).permit(
      :name, :query, :sources,
      :date_from, :time_from, :date_to, :time_to, :relative_timestamp,
      :host_from, :host_to,
      :search_type, :group_by,
      :query_params,
      search_fields_attributes: [
        :id, :_destroy,
        :and_or, :data_source_id, :data_source_field_id, :match_or_attribute_value
      ]
    )
  end

  # def remove_ids_from_search_params
  #   # note: search_fields_attributes are assigned id's when errors occur,
  #   #       so we remove them since no records are in the db for this search:
  #   return if params['search']['search_fields_attributes'].blank?
  #   params['search']['search_fields_attributes'].each { |k,v| v.delete('id') }
  # end
end
