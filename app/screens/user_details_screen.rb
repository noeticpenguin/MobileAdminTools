class UserDetailsScreen < ProMotion::GroupedTableScreen
	include ProMotion::Table
	title "User Details"
	refreshable callback: :on_refresh,
	pull_message: "Pull to refresh",
	refreshing: "Refreshing data…",
	updated_format: "Last updated at %s",
	updated_time_format: "%l:%M %p"

	attr_accessor :id

	def on_load
		@basic_info = %w{Username IsActive Name Division Department Title Email Phone Fax MobilePhone Alias CommunityNickname EmployeeNumber ReceivesInfoEmails ReceivesAdminInfoEmails}
		@audit_info = %w{LastLoginDate LastPasswordChangeDate CreatedDate CreatedBy LastModifiedDate LastModifiedBy}
		@sub_screens = %w{UserRole Profile Manager}
		@user_perms = %w{UserPermissionsMarketingUser UserPermissionsOfflineUser UserPermissionsCallCenterAutoLogin UserPermissionsMobileUser UserPermissionsSFContentUser UserPermissionsKnowledgeUser UserPermissionsInteractionUser UserPermissionsSupportUser UserPermissionsSiteforceContributorUser UserPermissionsSiteforcePublisherUser UserPermissionsChatterAnswersUser ForecastEnabled  UserPreferencesContentNoEmail UserPreferencesContentEmailAsAndWhen UserPreferencesApexPagesDeveloperMode
		}
		@t = {Username: "Username", IsActive: "Active", Name: "Name", Division: "Division", Department: "Department", 
			Title: "Title", Email: "Email", Phone: "Phone", Fax: "Fax",	MobilePhone: "Cell", Alias: "Alias", 
			CommunityNickname: "Nickname", EmployeeNumber: "Employee Number", ReceivesInfoEmails: "Receives Info Emails",
			ReceivesAdminInfoEmails: "Receives Admin Emails", LastLoginDate: "Last Login Date",
			LastPasswordChangeDate: "Pw Changed on", CreatedDate: "Created On",	CreatedBy: "Created By",
			LastModifiedDate: "Modified On", LastModifiedBy: "Modified By",	UserRole: "Role",	Profile: "Profile",
			Manager: "Manager",	DelegatedApproverId: "Delegated Approver", UserPermissionsMarketingUser: "Marketing User",
			UserPermissionsOfflineUser: "Offline User", UserPermissionsCallCenterAutoLogin: "Call Center Autologin",
			UserPermissionsMobileUser: "Mobile User",	UserPermissionsSFContentUser: "Content User",
			UserPermissionsKnowledgeUser: "Knowledge User",	UserPermissionsInteractionUser: "Interaction User",
			UserPermissionsSupportUser: "Support User", UserPermissionsSiteforceContributorUser: "Siteforce Contributor",
			UserPermissionsSiteforcePublisherUser: "Siteforce Publisher",	UserPermissionsChatterAnswersUser: "Chatter Answers User",
			ForecastEnabled: "Forcast Enabled",	UserPreferencesContentNoEmail: "Content No Email", 
			UserPreferencesContentEmailAsAndWhen: "Content Email As",	UserPreferencesApexPagesDeveloperMode: "VF Developer Mode"
		}
	end

	def on_appear
		Flurry.logEvent("UserDetailScreenLaunched")
		get_describe_for_user
		@refresh_table_data = true
	end

	def on_refresh
		get_describe_for_user
		update_table_data
	end

	def get_describe_for_user
		dscribe = SFRestAPI.sharedInstance.performDescribeWithObjectType('User',
			failBlock: lambda {|e| ap e},
			completeBlock: method(:create_query)
		)
	end

	def create_query describe 
		@wanted_fields = @basic_info + @audit_info + @sub_screens + @user_perms
		@included_fields = describe["fields"].map {|f| f["name"] if @wanted_fields.include? f["name"]}.compact!.join ", "
		query_sf_for_user_details @included_fields
	end

	def query_sf_for_user_details query_string
		results = SFRestAPI.sharedInstance.performSOQLQuery(
			#query to run 
			"SELECT #{query_string}, LastModifiedBy.Name, CreatedBy.Name, UserRole.Name, Profile.Name, Manager.Name FROM user WHERE Id = '#{@id}'", 
			failBlock: lambda {|e| ap e }, #lambda to run in case of failure. @todo I should throw a modal warning here.
			completeBlock: method(:setup_table_data) #lambda to run in case of success
		)
	end

	def setup_table_data data
		@data = []
		basic = {cells: []}
		audit = {title: "Audit Information", cells: []}
		subs = {title: "Additional Information", cells: []}
		perms = {title: "User Permissions", cells: []}
		data = data["records"][0]
		
		data.keys.each do |k|
			to_add = nil #reset to_add
			v = data[k]
			#subqueries, such as manager.Name come in as a subhash.
			v = v["Name"] if (v.respond_to? :keys) && (v.keys.include? "Name")
			if (k.downcase.include? "date")
				v = v.split("T").first if v.respond_to?(:split)
			end

			next if v.nil? || k == "attributes"
			if @basic_info.include? k
				if k == "Name"
					basic[:title] = v 
				else
					if v == true || v == false #if this is a switch
						to_add = {
							title: @t[k.to_sym],
							cell_identifier: 'switch_cell',
							accessory: {
								view: :switch,
								action: :toggle_switch,
								value: v,
								arguments: {
									key: k
								}
							}
						}
					else #or not a switch
						to_add = {
							title: @t[k.to_sym],
							cell_style: UITableViewCellStyleValue1,
							subtitle: v,
							cell_identifier: 'static_data_cell'
						}
					end
					basic[:cells] << to_add
				end
			elsif @audit_info.include? k
				to_add = {
					title: @t[k.to_sym],
					subtitle: v,
					cell_style: UITableViewCellStyleValue1,
					cell_identifier: 'static_data_cell'
				}
				audit[:cells] << to_add
			elsif @sub_screens.include? k
				to_add = {
					title: @t[k.to_sym],
					subtitle: v,
					# action: :open_sub_screen, arguments: {id: @id, key: k, value: v },
					cell_identifier: 'static_data_cell'
				}
				subs[:cells] << to_add
			elsif @user_perms.include? k
				to_add = {
					title: @t[k.to_sym],
					cell_identifier: 'switch_cell',
					accessory: {
						view: :switch,
						action: :toggle_switch,
						value: v,
						arguments: {
							key: k
						}
					}
				}
				perms[:cells] << to_add
			end
		end

		audit[:cells].insert(0, {title: "Trigger Password Reset", action: :reset_password, arguments: {id: @id } })
		audit[:cells].insert(1, {title: "Login History", action: :login_history, arguments: {id: @id} })

		@data << basic
		@data << audit
		@data << subs
		@data << perms
		update_table_data if @refresh_table_data
		@refresh_table_data = false
		end_refreshing
	end

	def table_data
		@data
	end

	def open_sub_screen args
	end

	def login_history args
		open_screen LoginHistoryScreen.new id: args[:id]
	end

	def reset_password args
		UIAlertView.alert("Reset Users Password?", buttons: ["Cancel", "OK"],
			message: "Salesforce will send a password reset email to Users email address") { |button|
			if button == "OK"
				results = SFRestAPI.sharedInstance.requestPasswordResetForUser(
					@id, # id of user to invoke password reset. 
					failBlock: lambda {|e| ap e }, #lambda to run in case of failure. @todo I should throw a modal warning here.
					completeBlock: method(:password_reset_complete) #lambda to run in case of success
				)
			end
		}
	end

	def password_reset_complete response
		Flurry.logEvent("passwordReset")
		if(Twitter.accounts.size > 0) #we have a twitter account!
			UIAlertView.alert("Password Reset!", buttons: ["OK", "Tweet"]) { |button|
				if button == "Tweet"
					tweet
				end
			}
		end
	end

	def tweet
		Flurry.logEvent("UserTweeted")
		rand = ["#MightBeInTheRestroom", "#MightBeInAMeeting", "#AtHappyHour", 
						"#LessThan30Seconds", "#DoneWhileWalking", "#MightBeStuckInTraffic"].sample
		Twitter.accounts[0].compose(presenting_controller: self, 
			tweet: "Another Password Reset with Mobile Admin Tools #{rand} #WhySFDCAdminsDrinkLess") do |composer|
			if composer.error
				ap "Composer Error"
			elsif composer.cancelled?
				ap "Composer Canceled"
			elsif composer.done?
				ap "Composer Success!"
			end
		end
	end

	def toggle_switch arguments
		Flurry.logEvent("userSettingUpdated")
		ap arguments
		SFRestAPI.sharedInstance.performUpdateWithObjectType(
			"User", #hardcoded to User, since that's what we're using
			objectId: @id, #the Id to update
			fields: {arguments[:key] => arguments[:value]},
			failBlock: method(:toggle_fail),
			completeBlock: lambda {|e| ap e}
		)
	end

	def toggle_fail response
		Flurry.logEvent("InvalidPropertyToggle")
		UIAlertView.alert("Unable to Update User Record", buttons: ["OK"],
			message: "#{response.userInfo["message"]}") { |button|
			if button == "OK"
			end
		}
	end

end