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
	# These are the minimum required libraries for use with the Salesforce mobile iOS SDK
	app.libs << "/usr/lib/libxml2.2.dylib" # <- XML? ... yeah, we need it.
	app.libs << "/usr/lib/libsqlite3.0.dylib" # <- Need to link against Sqlite 3
	app.libs << "/usr/lib/libz.dylib" # <- Need to link against zlib
	# This rakefile assumes you're following the practice of placing a copy of the Salesforce
	# iOS sdk under <<ProjectRoot>>/vendor/Salesforce
	app.libs << "vendor/Salesforce/dist/openssl/openssl/libcrypto.a" # <- Salesforce provided crypto lib
	app.libs << "vendor/Salesforce/dist/openssl/openssl/libssl.a" # <- Salesforce provided SSL lib
	app.libs << "vendor/Salesforce/dist/sqlcipher/sqlcipher/libsqlcipher.a" # <- Salesforce Provided Sqlite Encryption library
	app.libs << "vendor/Salesforce/dist/SalesforceCommonUtils/Libraries/libSalesforceCommonUtils.a" # <- Salesforce provided, Non-open source library!
	
	#### Entitlements
	# In order for the application to securely store oAuth credentials, Salesforce apps need
	# the keychain-access-groups entitlement, this shouldn't change.
	app.entitlements['keychain-access-groups'] = [
		app.seed_id + '.' + app.identifier
	]

	#### Vendor Projects, because sometimes, precompiled code sucks.
	# While Salesforce provides precompiled versions of the following libraries under
	# /vendor/Salesforce/dist/<<Lib Name>> the following libraries *MUST* be compiled
	# so that rubymotion builds, and includes the bridgesupport file. This provides 
	# Rubymotion with access to methods that are in Obj-c categories etc. 
	
	# Restkit, because the pod isn't good enough.
	# YOU MUST USE THE SALESFORCE DISTRIBUTED VERSION
	# YOU MUST HAND COMPILE IT VIA VENDOR_PROJECT TO AVOID
	#   RANDOM SELECTOR_NOT_FOUND ERRORS. THAT IS ALL.
	app.vendor_project "vendor/Salesforce/external/RestKit/RestKit", # <- path to root of library source
		:xcode, # <- either :xcode or :static, use :xcode if there is a .xcodeproj file present
		:target => 'RestKit', # <- if :xcode, specify the target you want to build
		:headers_dir => "build/RestKit" # <- *this is the crucial bit* RubyMotion builds the
						# .bridgesupport file from the headers, 
						# YOU MUST SPECIFY THE HEADER DIR.

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
	app.vendor_project "vendor/Salesforce/native/SalesforceSDK", 
		:xcode,
		:target => "SalesforceSDK",
		:headers_dir => "SalesforceSDK/Classes" # <- This is the most crucial .bridgesupport file
							# to be generated. 
	
	#### CocoaPods!
	# Who doesn't love them some cocoaPod goodness?
	app.pods do
		# pod 'RestKit' # <- Salesforce relies on THEIR FORK! DO NOT USE POD
		pod 'FlurrySDK' # <- Flury Mobile Analytics SDK, this is optional, but Mobile Data Tools uses it.
		pod 'Appirater' # <- Cocoa Pod for built in automatic prompting of "rate my app please", Options but Mobile Data Tools uses it.
		pod 'MGSplitViewController' # <- A more feature rich split view controller, here as an example
		pod 'MBProgressHUD' # <- For displaying pretty spinners with "wait already!" messages. Not in use in this app.
		# pod 'SQLCipher' # <- don't use this. #iWasTemptedToo. #fail.
		# pod 'FMDB' # <- Database wrapper not unlike active record. Not in use in this app
	end

	#TestFlight!
	# While test flight is normally included via a cocoapod, RubyMotion has it's own Gem. This sets it up.
	# This is optional, but highly recommended for on-device testing.
	app.testflight.sdk = 'vendor/TestFlight'
	app.testflight.api_token = '<<< TEST FLIGHT API TOKEN HERE >>>'
	app.testflight.team_token = '<<< TEST FLIGHT TEAM TOKEN HERE >>>'

end # <- End App.setup block. 


### Helper Rake Tasks
# These Rake tasks are helper tasks designed to make development smoother / better / faster / stronger!
# #6million$Dev

desc "Open latest crash log" # <- When the app crashes in the simulator it writes a .datXXXX file in the root 
				# of the project containing the crash log. this opens the latest one.
task :log do
	app = Motion::Project::App.config
	exec "less '#{Dir[File.join(ENV['HOME'], "/Library/Logs/DiagnosticReports/#{app.name}*")].last}'"
end

desc "Run simulator in retina mode" # <- default is non-retina mode
task :retina do
	exec "bundle exec rake simulator retina=true"
end

desc "Run simulator on iPad" # <- Run on an Ipad, if device family includes :ipad
task :ipad do
	exec "bundle exec rake simulator device_family=ipad"
end

```

## Additions / modifications to the SFRestAPI and SFRestAPI+Blocks classes
This app allows administrators to issue a password reset request for a given user. In order to do so, additional methods were added to the Salesforce provided SFRestAPI and SFRestAPI+Blocks classes. Details of those changes are here:

```Obj-c
// Found in: SFRestAPI.m
// The Password management endpoint was added in api v24.0, so we must use at least that version.
// SDK ships with a default of v23.0
NSString* const kSFRestDefaultAPIVersion = @"v24.0";
```

```Obj-c
// Found in: SFRestAPI.h
/**
 * Returns a `SFRestRequest` which executes a user password reset.
 * @param uid a string containing the uuid of the user who's password should be reset.
 * @see http://www.salesforce.com/us/developer/docs/api_rest/Content/resources_sobject_user_password.htm
 */
- (SFRestRequest *)requestForUserPasswordReset:(NSString *)uid;
```

```Obj-c
// Found in: SFRestAPI.m
- (SFRestRequest *)requestForUserPasswordReset:(NSString *)uid {
    NSString *path = [NSString stringWithFormat:@"/%@/sobjects/User/%@/password", self.apiVersion, uid];
    return [SFRestRequest requestWithMethod:SFRestMethodDELETE path:path queryParams:nil];
}
```

###And for Blocks support
```Obj-c
// Found in: SFRestAPI+Blocks.h
/**
 * Executes a request to reset a users password via REST API
 * @param failBlock the block to be exectured when the request fails (timeout, cancel, or error)
 * @param coompleteBlock the block to be executed when the request successfully completes
 * @return the newly sent SFRestRequest
 */
- (SFRestRequest *) requestPasswordResetForUser:(NSString *)query 
                                      failBlock:(SFRestFailBlock)failBlock 
                                  completeBlock:(SFRestDictionaryResponseBlock)completeBlock;
```

```Obj-c
// Found in: SFRestAPI+Blocks.m
- (SFRestRequest *) requestPasswordResetForUser:(NSString *)uid failBlock:(SFRestFailBlock)failBlock completeBlock:(SFRestDictionaryResponseBlock)completeBlock {
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUserPasswordReset:uid];
    [self sendRESTRequest:request
                failBlock:failBlock
            completeBlock:completeBlock];
    
    return request;
}
```
