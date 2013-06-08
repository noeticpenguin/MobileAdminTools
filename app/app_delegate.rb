class AppDelegate < SFNativeRestAppDelegate

	include ProMotion::ScreenTabs
	include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
	include ProMotion::DelegateHelper
	include ProMotion::DelegateNotifications

	attr_accessor :splitViewController, :aps_notification
	
	# static NSString *const OAuthLoginDomain = @"test.salesforce.com";
	def oauthLoginDomain()
		"test.salesforce.com"
	end

	def remoteAccessConsumerKey()
		'3MVG9y6x0357HledkDGHVNgI_1aBN9wuU4g1Nulz.PBAYr3Q.76MuHhUbgdsFhWQhmy7hQ0RUBJDCiWy02ZvF'
	end

	def oauthRedirectURI()
		'testsfdc:///mobilesdk/detect/oauth/done'
	end

	def application(application, didFinishLaunchingWithOptions:launchOptions)
		super
		apply_status_bar
		# on_load application, launchOptions
		check_for_push_notification launchOptions
		true
	end

	def applicationWillTerminate(application)
			on_unload if respond_to?(:on_unload)
	end

	def on_load(app, options)
	# 	ap "on_load running ---- woot"
	# 	# @home = HomeScreen.new
	# 	# @home.navigation_controller = @navController
	# 	# # @home.navigationController = @navController 
	# 	# # You shouldn't have to do this, but if it doesn't work, do it. 
	# 	# # This might be a bug. Report it if you do indeed have to enable this line.
	# 	# open @home
	end

	def newRootViewController
		@home = HomeScreen.new
		# @navController = UINavigationController.alloc.initWithRootViewController(RootViewController.alloc.initWithNibName(nil, bundle: nil))
		@navController = UINavigationController.alloc.initWithRootViewController(@home)
		@navController
	end

end