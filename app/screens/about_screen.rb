class AboutScreen < ProMotion::GroupedTableScreen

	def table_data
		[
			{
				title: "About Mobile Admin Tools",
				cells: [
					{ title: "By",
						subtitle: "Kevin Poorman",
						cell_style: UITableViewCellStyleValue1
					},
					{ title: "Version",
						subtitle: "1.0",
						cell_style: UITableViewCellStyleValue1
					},
					{ title: "Follow me on Twitter @CodeFriar", 
						action: :twitter
					},
				]
			},
			{
				title: "Help",
				cells: [
					{ title: "Github Issues",
					 action: :support
					},
					{ title: "Source",
					 action: :github
					}
				]
			},
			{
				title: "Special Thanks",
				cells: [
					{ title: "Madrona Solutions Group",
						action: :madrona
					},
					{ title: "ProMotion Authors",
						action: :promotion
					},
					{ title: "Salesforce Dev Evangelists",
						action: :twitter_forcedotcom
					}
				]
			}
		]
	end

	def support
		"https://github.com/noeticpenguin/MobileAdminTools/issues".nsurl.open
	end

	def github
		"http://noeticpenguin.github.io/MobileAdminTools".nsurl.open
	end

	def madrona
		"http://www.madronasg.com".nsurl.open
	end

	def promotion
		"https://github.com/clearsightstudio/ProMotion".nsurl.open
	end

	def twitter
		"http://www.twitter.com/codefriar".nsurl.open
	end

	def twitter_forcedotcom
		"http://www.twitter.com/forcedotcom".nsurl.open
	end

end