class HomeScreen < ProMotion::TableScreen
	title "Users"
	searchable placeholder: "Search Users"
	refreshable callback: :on_refresh,
	pull_message: "Pull to refresh",
	refreshing: "Refreshing data…",
	updated_format: "Last updated at %s",
	updated_time_format: "%l:%M %p"

	def on_appear
		add_nav_bar
		set_nav_bar_button :right, title: "Logout", action: :logout, type: UIBarButtonItemStyleDone
		set_nav_bar_button :left, title: "About", action: :about, type: UIBarButtonItemStyleDone
		query_sf_for_users
		@refresh_table_data = true
	end

	def query_sf_for_users
		results = SFRestAPI.sharedInstance.performSOQLQuery(
			"Select id, name, LastName from user", #query to run 
			failBlock: lambda {|e| ap e }, #lambda to run in case of failure. @todo I should throw a modal warning here.
			completeBlock: method(:sort_results) #lambda to run in case of success
		) 
	end

	def sort_results(unsorted)
		@data = []
		("A".."Z").each do |l|
			cells = unsorted["records"].select {|i| i["LastName"].starts_with? l}
			group = {
				title: l,
				cells: cells.map do |c|
					{ title: c["Name"], action: :open_user, arguments: {id: c["Id"] } }
				end
			}
			@data << group
		end

		update_table_data if @refresh_table_data
		@refresh_table_data = false
		end_refreshing
		@data
	end

	def on_refresh
		query_sf_for_users
		update_table_data
	end

	def table_data
		@data
	end

	def table_data_index
		return ("A".."Z").to_a
  	# table_data.collect{|section| section[:title][0] } unless table_data.nil?
	end

	def about
		open_screen AboutScreen.new
	end

	def logout
		UIAlertView.alert("Logout?", buttons: ["Cancel", "OK"],
			message: "Logout from this Salesforce Org?") { |button|
			if button == "OK"
				App.delegate.logout
				App.delegate.navController = nil
			end
		}
	end

	def open_user(args)
		# ap args #[:cell][:title]
		open_screen UserDetailsScreen.new id: args[:id]
	end

end