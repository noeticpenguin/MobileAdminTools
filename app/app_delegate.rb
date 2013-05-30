class AppDelegate < SFNativeRestAppDelegate

  attr_accessor :splitViewController
  
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
  end

  def newRootViewController
    # # Generate the listViewController object for the split view:
    # listViewController = ObjectListController.alloc.initWithNibName(nil, bundle: nil)
    # # Generate the detail view
    # detailsViewController = DetailViewDefaultController.alloc.init
    # # Generate the split view controller
    # @splitViewController = MGSplitViewController.alloc.init

    # # Give the splitViewController access to the detail view.
    # @splitViewController.delegate = detailsViewController
    # # Give the list view access to the detail view
    # listViewController.delegate = detailsViewController

    # # generate a Nav controller for the detail view, and assign the root view to the detail view controller
    # detailsNav = UINavigationController.alloc.initWithRootViewController(detailsViewController)
    # # Assign the listview and the detail nav  controllers to the split view.
    # @splitViewController.viewControllers = [listViewController, detailsNav]
    # # splitViewController.modalTransitionStyle = UIModalPresentationCurrentContext
    # # puts "############## #{splitViewController.modalTransitionStyle}"

    # @splitViewController
    # #origial
    @navController = UINavigationController.alloc.initWithRootViewController(RootViewController.alloc.initWithNibName(nil, bundle: nil))
    @navController
  end

end