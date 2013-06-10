class LoginHistoryScreen < ProMotion::GroupedTableScreen
  include ProMotion::Table
	title "Login History"
  refreshable callback: :on_refresh,
  pull_message: "Pull to refresh",
  refreshing: "Refreshing data…",
  updated_format: "Last updated at %s",
  updated_time_format: "%l:%M %p"
  
  attr_accessor :id

	def on_load

	end

  def on_appear
    @refresh_table_data = true
    query_for_login_history
  end

  def query_for_login_history
    results = SFRestAPI.sharedInstance.performSOQLQuery(
      #query to run 
      "SELECT LoginTime, LoginType, SourceIp, LoginUrl, Browser, Platform, Status, Application, ClientVersion, ApiType, ApiVersion from LoginHistory WHERE UserId = '#{@id}' ORDER BY LoginTime Desc LIMIT 15", 
      failBlock: lambda {|e| ap e }, #lambda to run in case of failure. @todo I should throw a modal warning here.
      completeBlock: method(:setup_table_data) #lambda to run in case of success
    )
  end

  def setup_table_data data
    @data = []
    data["records"].each do |row|
      to_add = {
        title: "#{row["LoginTime"]}",
        cells: []
      }

      row.keys.each do |key|
        value = row[key];
        next if value.nil?
        next if key == "attributes"
        cell = { title: key.split(/(?=[A-Z])/).join(" "),
                  subtitle: value.to_s,
                  cell_style: UITableViewCellStyleValue1,
                  cell_identifier: 'static_data_cell'
                }
        to_add[:cells].push(cell)
      end
      @data.push(to_add)
    end
    update_table_data if @refresh_table_data
    @refresh_table_data = false
    end_refreshing
  end

  def table_data
    @data
  end

  def on_refresh
    query_for_login_history
    update_table_data
  end

end