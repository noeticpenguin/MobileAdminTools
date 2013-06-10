MobileAdminTools
================

## What is Mobile Admin Tools?

I wanted to write an app that would help admins do their jobs more easily and efficiently, and a poll of 25 or so admins revealed that the top 2 real-world frustrations for Salesforce admins are password resets and user management. Mobile Admin Tools was created to help with those two pain points. 

Features you should note: 

   * The "pull to refresh" functionality builtin to all data viws 

   * The searchable user view with index on the side.  


Most importantly, while viewing a particular user, admins can: 


   * Deactivate and / or (re)activate users, 

   * Initiate password reset, show email

      * Just for fun, I added the option to tweet on password reset to share such inspirational tidbits as "Just reset a user password from my phone.  MobileAdminTools ftw!  #MightBeAtTheBar" 
      * This isn't intended to name & shame users for needing their password reset, but rather to socialize Mobile Admin Tools and bring a bit of levity to otherwise frustratingly boring work.

   * View login history and other important user details such as role and profile, 

   * Manage user settings - all from their iPhones.  



Please note, this app utilizes the Salesforce native iOS SDK; however it is written in RubyMotion.

## YouTube Video Demonstration
YouTube Video - Mobile Admin Tools | http://www.youtube.com/watch?v=nqC7KaQwwgk

## Rakefile Details
As those familiar with RubyMotion will no doubt recognize, the Rakefile is central to a Rm project's management.
What follows is an annontated rakefile detailing whats needed to utilize the Salesforce Mobile Sdk iOS (1.x v) 
SDK within a RubyMotion project. 

A quick note: I have discovered a commonly held, but incorrect belief that RubyMotion projects are:
* Slow
* Not native applications
* Unable to utilize the native SDK's and Frameworks
* Unable to access / utilize open source cocoaTouch projects via CocoaPods.

None of the above are true, and this project demonstrates a *fast* (well, depending on your network connection)
*native* iOS application that utilizes not only iOS frameworks like UIKit but also third party frameworks, and *cocoapoods*

```ruby
# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'rubygems'
require 'bundler'

Bundler.require
require 'sugarcube-repl'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
	#### General Information
	app.name = 'Mobile Admin Tools' # <-Set your project name here.
	app.version = "1.0" # <- This is especially useful during TestFlight testing!
	app.deployment_target = "6.0" # <- Minimum OS version for client device
	app.device_family = [:iphone] # <- What devices can run this? other options include: :ipad
	app.interface_orientations = [:portrait, :landscape_left, :landscape_right] # <- Hopefully obvious
	
	#### Application Artwork. 
	app.icons = ["Icon.png",    # <- iPhone non-retina standard icon
							 "Icon@2x.png"] # <- Retina iPhone icon

	#### Application Frameworks
  # This next line details the list of iOS frameworks that this application will require.
  # While this list is specific to this application, it's pretty much the bare minimum needed
  # for utilizing the Salesforce mobile SDK (iOS)
	app.frameworks += %w(CFNetwork CoreData MobileCoreServices SystemConfiguration Security MessageUI QuartzCore OpenGLES CoreGraphics sqlite3)
	
	#### Code signature, profile and Identifier info. ##Headache##
  # Note well the difference between development (simulator use) and relase (on device use)!
	app.development do
		app.entitlements['get-task-allow'] = true
		# app.identifier = '<<< INSERT YOUR APP IDENTIFIER HERE >>>'
		# app.provisioning_profile = '<<< INSERT FULL PATH TO YOUR PROVISIONING PROFILE HERE >>>'
		# app.codesign_certificate = '<<< INSERT NAME OF CODE SIGN CERTIFICATE HERE >>>'
	end

	app.release do
		app.entitlements['get-task-allow'] = false # <- THIS IS CRUCIAL
  	# app.identifier = '<<< INSERT YOUR APP IDENTIFIER HERE >>>'
		# app.provisioning_profile = '<<< INSERT FULL PATH TO YOUR PROVISIONING PROFILE HERE >>>'
		# app.codesign_certificate = '<<< INSERT NAME OF CODE SIGN CERTIFICATE HERE >>>'
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
	# 	NOT FOUND ERROR ON MACADDRESS. #JUSTSAYING.
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
		pod 'Appirater' #RATE MY APP DARN YOU!
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
```
