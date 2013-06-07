class UserDetailsScreen < ProMotion::GroupedTableScreen

	title "User Details"
	refreshable callback: :on_refresh,
	pull_message: "Pull to refresh",
	refreshing: "Refreshing data…",
	updated_format: "Last updated at %s",
	updated_time_format: "%l:%M %p"

	attr_accessor :id

	def on_load
		ap self.id
		# results = SFRestAPI.sharedInstance.performSOQLQuery(
		# 	"Select id, FirstName, LastName,  from user", #query to run 
		# 	failBlock: lambda {|e| ap e }, #lambda to run in case of failure. @todo I should throw a modal warning here.
		# 	completeBlock: method(:sort_results) #lambda to run in case of success
		# )
	end

	def on_appear
		query_sf_for_user_details
		@refresh_table_data = true
	end

	def query_sf_for_user_details

	end

	def table_data
		[{
			title: "ProMotion",
			cells: [
				{ 
					title: "About ProMotion", 
					action: :about_promotion,
					accessory: :switch, # currently only :switch is supported
      		accessory_view: @some_accessory_view,
      		accessory_checked: true,
				},
				{ title: "About Jamon", action: :about_jamon }
			]
		}, {
			title: "Help",
			cells: [
				{ title: "Support", action: :support },
				{ title: "Feedback", action: :feedback }
			]
		}]
	end



end