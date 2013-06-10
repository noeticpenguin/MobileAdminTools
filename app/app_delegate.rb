class AppDelegate < SFNativeRestAppDelegate

	include ProMotion::ScreenTabs
	include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2") # Only with iPad
	include ProMotion::DelegateHelper
	include ProMotion::DelegateNotifications

	attr_accessor :splitViewController, :aps_notification, :navController
	
	# static NSString *const OAuthLoginDomain = @"test.salesforce.com";
	# Useful for forcing authentication to a sandbox domain.
	def oauthLoginDomain()
		# "test.salesforce.com"
		"login.salesforce.com"
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
		check_for_push_notification launchOptions
		true
	end

	def applicationWillTerminate(application)
			on_unload if respond_to?(:on_unload)
	end

	#Flurry exception handler
	def uncaughtExceptionHandler(exception)
		Flurry.logError("Uncaught", message:"Crash!", exception:exception)
	end

	#apirater setup
	Appirater.setAppId NSBundle.mainBundle.objectForInfoDictionaryKey('APP_STORE_ID')
	Appirater.setDaysUntilPrompt 5
	Appirater.setUsesUntilPrompt 10
	Appirater.setTimeBeforeReminding 5
	Appirater.appLaunched true

	def on_load(app, options)
		@home = HomeScreen.new
		
		unless Device.simulator?
			NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
			Flurry.startSession("Z579ZYX298X3HM6RFF9W")
		end
	end

	def newRootViewController
		@navController = UINavigationController.alloc.initWithRootViewController(@home)
		@navController
	end

end