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
		@basic_info = %w{Username IsActive Name Division Department Title Email Phone Fax MobilePhone Alias CommunityNickname EmployeeNumber ReceivesInfoEmails ReceivesAdminInfoEmails}
		@audit_info = %w{LastLoginDate LastPasswordChangeDate CreatedDate CreatedById LastModifiedDate LastModifiedById}
		@sub_screens = %w{UserRoleId ProfileId ManagerId DelegatedApproverId}
		@user_perms = %w{UserPermissionsMarketingUser UserPermissionsOfflineUser UserPermissionsCallCenterAutoLogin UserPermissionsMobileUser UserPermissionsSFContentUser UserPermissionsKnowledgeUser UserPermissionsInteractionUser UserPermissionsSupportUser UserPermissionsSiteforceContributorUser UserPermissionsSiteforcePublisherUser UserPermissionsChatterAnswersUser ForecastEnabled UserPreferencesActivityRemindersPopup UserPreferencesEventRemindersCheckboxDefault UserPreferencesTaskRemindersCheckboxDefault UserPreferencesReminderSoundOff UserPreferencesContentNoEmail UserPreferencesContentEmailAsAndWhen UserPreferencesApexPagesDeveloperMode UserPreferencesHideCSNGetChatterMobileTask UserPreferencesHideCSNDesktopTask UserPreferencesOptOutOfTouch UserPreferencesShowTitleToExternalUsers UserPreferencesShowManagerToExternalUsers UserPreferencesShowEmailToExternalUsers UserPreferencesShowWorkPhoneToExternalUsers UserPreferencesShowMobilePhoneToExternalUsers UserPreferencesShowFaxToExternalUsers UserPreferencesShowStreetAddressToExternalUsers UserPreferencesShowCityToExternalUsers UserPreferencesShowStateToExternalUsers UserPreferencesShowPostalCodeToExternalUsers UserPreferencesShowCountryToExternalUsers
		}
	end

	def on_appear
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
			"SELECT #{query_string} FROM user WHERE Id = '#{@id}'", #query to run 
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
			next if v.nil?
			if @basic_info.include? k
				if k == "Name"
					basic[:title] = v 
				else
					if v == true || v == false
						to_add = {
							title: k,
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
					else
						to_add = {
							title: k,
							cell_style: UITableViewCellStyleValue1,
							subtitle: v,
							cell_identifier: 'static_data_cell'
						}
					end
					basic[:cells] << to_add
				end
			elsif @audit_info.include? k
				to_add = {
					title: k,
					subtitle: v,
					cell_style: UITableViewCellStyleValue1,
					cell_identifier: 'static_data_cell'
				}
				audit[:cells] << to_add
			elsif @sub_screens.include? k
				to_add = {
					title: k,
					action: :open_sub_screen, arguments: {id: @id, key: k, value: v },
					cell_identifier: 'static_data_cell'
				}
				subs[:cells] << to_add
			elsif @user_perms.include? k
				to_add = {
					title: k,
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

	def reset_password args
		ap args
	end

	def toggle_switch arguments
		ap arguments
	end

end