# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'rubygems'
require 'bundler'
require 'bubble-wrap/reactor'
Bundler.require
require 'sugarcube-repl'

Motion::Project::App.setup do |app|
	# Use `rake config' to see complete project settings.
	#### General Information
	app.name = 'mobileAdmin2'
	app.version = "1.0"
	app.deployment_target = "6.0" #Minimum OS version for client device
	app.device_family = [:iphone, :ipad] #what devices can run this?
	app.interface_orientations = [:portrait, :landscape_left, :landscape_right] #hopefully obvious
	
	#### Application Artwork. 
	app.icons = ["Icon.png",    # ipad and iphone 3 standard icon
							 "Icon@2x.png", # Retina iphone/ipad icon
							 "Icon-72.png", # Fill in as you learn
							 "Icon-58.png", # Fill in as you learn
							 "Icon-29.png"] # Fill in as you learn

	#### Application Frameworks
	app.frameworks += %w(CFNetwork CoreData MobileCoreServices SystemConfiguration Security MessageUI QuartzCore OpenGLES CoreGraphics sqlite3)
	
	#### Code signature, profile and Identifier info. ##Headache##
	app.development do
		app.entitlements['get-task-allow'] = true
		# app.identifier = '745ST2PM9F.com.brightleafsoftware.*'
		# app.provisioning_profile = '/Users/kpoorman/Library/MobileDevice/Provisioning Profiles/BCDD81BF-A03A-4125-A512-1CEA3D370599.mobileprovision'
		# app.codesign_certificate = 'iPhone Distribution: Kevin Poorman'
	end

	app.release do
		app.entitlements['get-task-allow'] = false
		# app.codesign_certificate = 'iPhone Distribution: Kevin Poorman'
		# app.provisioning_profile = "Madrona_Mobile_Admin_Tools_ad_hoc.mobileprovision"
	end
	
	#### Additional Libraries Needed
	app.libs << "/usr/lib/libxml2.2.dylib"
	app.libs << "/usr/lib/libsqlite3.0.dylib"
	app.libs << "/usr/lib/libz.dylib"
	app.libs << "vendor/Salesforce/dist/openssl/openssl/libcrypto.a"
	app.libs << "vendor/Salesforce/dist/openssl/openssl/libssl.a"
	app.libs << "vendor/Salesforce/dist/sqlcipher/sqlcipher/libsqlcipher.a"
	app.libs << "vendor/Salesforce/dist/SalesforceCommonUtils/Libraries/libSalesforceCommonUtils.a"
	# app.libs << "vendor/Salesforce/dist/SalesforceSDK/SalesforceSDK/libSalesforceSDK.a"
	
	#### Entitlements
	app.entitlements['keychain-access-groups'] = [
		app.seed_id + '.' + app.identifier
	]

	#### Vendor Projects, because sometimes, precompiled code sucks.
	# Restkit, because the pod isn't good enough.
	# YOU MUST USE THE SALESFORCE DISTRIBUTED VERSION
	# YOU MUST HAND COMPILE IT VIA VENDOR_PROJECT TO AVOID
	# 	RANDOM SELECTOR_NOT_FOUND ERRORS. THAT IS ALL.
	app.vendor_project "vendor/Salesforce/external/RestKit/RestKit", 
		:xcode, 
		:target => 'RestKit', 
		:headers_dir => "build/RestKit"

	# Salesforce SDK oAuth Library
	# YOU MUST HAND COMPILE FROM SOURCE TO AVOID A SELECTOR
	# 	NOT FOUND ERROR ON MACADDRESS. @JUSTSAYING.
	app.vendor_project "vendor/Salesforce/native/SalesforceOAuth", 
		:xcode, 
		:target => 'SalesforceOAuth', 
		:headers_dir => "Headers/SalesforceOAuth"
	
	#  Salesforce SDK Libraries
	#  Yeah so trying the precompile versions in vendor dist is just 
	#  futile on stupid on #thisIsWhyDevsDrink. Even if you get it
	#  running, it'll bomb with weird ass errors.
	# app.vendor_project "vendor/Salesforce/native/SalesforceSDK", 
	# 	:xcode,
	# 	:scheme => "SalesforceSDK"
	
	app.vendor_project "vendor/Salesforce/native/SalesforceSDK", 
		:xcode,
		:target => "SalesforceSDK",
		:headers_dir => "SalesforceSDK/Classes"
	
	#### CocoaPods!
	# Who doesn't love them some cocoaPod goodness?
	app.pods do
		# pod 'RestKit' #Salesforce relies on THEIR VERSION! DO NOT USE POD
		pod 'FlurrySDK' #Flury Mobile Analytics SDK
		pod 'Appirater' #RATE MY APP DAMN YOU!
		pod 'MGSplitViewController' #A more feature rich split view controller
		pod 'MBProgressHUD' #For displaying pretty spinners with "wait already!" messages
		# pod 'SQLCipher' #don't use this. #iWasTemptedToo. #fail.
		# pod 'FMDB' #Database wrapper not unlike active record.
	end

	#TestFlight!
	app.testflight.sdk = 'vendor/TestFlight'
	app.testflight.api_token = '21ab92a1ea9dfaf5b11a2679a0db3555_ODQ3MDU4MjAxMy0wMS0yNSAxMzowNTo0NS42Njk4ODc'
	app.testflight.team_token = '1d010f0c240219bd97c8e4c40729e00b_MTc5NTc4MjAxMy0wMS0yOCAxNTowMTo1OC43MDY0MDM'

end

desc "Open latest crash log"
task :log do
	app = Motion::Project::App.config
	exec "less '#{Dir[File.join(ENV['HOME'], "/Library/Logs/DiagnosticReports/#{app.name}*")].last}'"
end

# Rake helper tasks

desc "Run simulator in retina mode"
task :retina do
	exec "bundle exec rake simulator retina=true"
end

desc "Run simulator on iPad"
task :ipad do
	exec "bundle exec rake simulator device_family=ipad"
end

desc "Run simulator on iPad in retina mode"
task :ipadretina do
	exec "bundle exec rake simulator retina=true device_family=ipad"
end
