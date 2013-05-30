class RootViewController < UITableViewController
  attr_accessor :data

  def didReceiveMemoryWarning()
    puts "memory error occured"
    super.didReceiveMemoryWarning
  end

  def viewDidLoad
    super

    # Setup our "Heads Up Display" working in background indicator
    # Note: Add this indicator's view to the navigationController's view
    # Or the Hud will appear behind the UiTableView's section headers.
    @hud = MBProgressHUD.alloc.initWithView(self.navigationController.view)
    @hud.labelText = "Refreshing"
    @hud.animationType = MBProgressHUDAnimationZoom
    self.navigationController.view.addSubview(@hud)
    @hud.show(true) # and turn the hud on.

    # Setup the Pull To Refresh
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action: :refresh, forControlEvents: UIControlEventValueChanged)
    self.refreshControl = @refreshControl

    # UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    # [refreshControl addTarget:self action:@selector(refresh)
    #      forControlEvents:UIControlEventValueChanged]; 
    # self.refreshControl = refreshControl;


    search_bar = UISearchBar.alloc.initWithFrame([[0,0],[320,44]])
    search_bar.delegate = self
    view.addSubview(search_bar)
    view.tableHeaderView = search_bar
    @search_results = []

    ap "Setting Title"
    self.title = "Users"
    
    ap "Setting Left Button"
    leftButton = UIBarButtonItem.alloc.initWithTitle("Logout", style: UIBarButtonItemStyleBordered, target:self, action:'logout')
    self.navigationItem.leftBarButtonItem = leftButton
    
    ap "refreshing if..."
    refresh if !load_from_cache
    @hud.hide(true)
  end

  def searchBarSearchButtonClicked(search_bar)
    @search_results.clear
    search_bar.resignFirstResponder
    navigationItem.title = "search results for '#{search_bar.text}'"
    search_for(search_bar.text)
    search_bar.text = ""
    ap "Setting Right Button"
    rightButton = UIBarButtonItem.alloc.initWithTitle("Reset", style: UIBarButtonItemStyleBordered, target:self, action:'refresh')
    self.navigationItem.rightBarButtonItem = rightButton
  end

  def search_for(text)
    search_results = @data.select {|k,v| v.size > 0 }.map {|k,v| v}.flatten.select {|x| x["Name"] =~ /#{text}/i}
    @data = reindex_table_data(search_results)
    tableView.reloadData
  end

  def refresh
    ap "Running Refresh"
    @hud.show(true)
    self.title = "Users"
    self.navigationItem.rightBarButtonItem = nil if self.navigationItem.rightBarButtonItem 
    request = SFRestAPI.sharedInstance.requestForQuery("SELECT Id, Name, LastName, Email FROM user")
    SFRestAPI.sharedInstance.send(request, delegate: self)
    @refreshControl.endRefreshing
  end

  def logout
    App.delegate.logout
  end

  def load_from_cache()
    ap "Running Load From Cache"
    @cached_users = UserCacheResult.load.records rescue nil
    return false if @cached_users.nil?
    @data = reindex_table_data(@cached_users)
    tableView.reloadData
  end

  # SFRestAPIDelegate
  def request(request, didLoadResponse: jsonResponse)
    ap "Executing Request:DidLoadResponse"
    if jsonResponse.keys.include?('NewPassword')
      alert = UIAlertView.alloc.init
      alert.message = "Password Reset issued for: #{@reset_for}"
      @reset_for = nil
      alert.addButtonWithTitle "OK"
      alert.show
      refresh
    else
      incoming = jsonResponse.objectForKey("records")
      @data = reindex_table_data(incoming)
    end
    @hud.hide(true)
    tableView.reloadData
  end

  def reindex_table_data(incoming)
    tmp = {}
    ("A".."Z").each do |l|
      tmp[l] = incoming.select {|i| i["LastName"].starts_with? l}
    end
    tmp
  end

  def request(request, didFailLoadWithError: error)
    puts "Request:DidFailLoadWithError: #{error}"
    # @todo: better error handling here.
  end

  def requestDidCancelLoad(request)
    puts "Request:requestDidCancelLoad: #{request}"
    # @todo: better error handling here.
  end

  def requestDidTimeout(request)
    puts "Request:requestDidTimeout: #{request}"
    # @todo: better error handling here.
  end

  #Table view data source

  # You must have a memoization style method for dealing with data-rows returned by an api to the tableview protocol.
  def data
    if @data.nil?
      @data = {}
    end
    return @data
  end

  def numberOfSelectionsInTableView(tableView)
    return 1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    # return data.count rescue 1
    row_for_section(section).count
  end

  def sections
    data.keys.sort
  end

  def row_for_section(section_index)
    data[self.sections[section_index]]
  end

  def row_for_index_path(index_path)
    row_for_section(index_path.section)[index_path.row]
  end

  def numberOfSectionsInTableView(tableView)
    self.sections.count rescue 1
  end

  def tableView(tableView, titleForHeaderInSection:section)
    sections[section]
  end

  def sectionIndexTitlesForTableView(tableView)
    sections
  end

  def tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    sections.index title
  end

  # Customize the appearance of table view cells.
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
    cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier) if cell.nil?
    image = UIImage.imageNamed('glyphicons_003_user.png')
    cell.imageView.image = image

    # Have the cell show data.
    rowObj = row_for_index_path(indexPath)
    cell.textLabel.text = rowObj["Name"]

    #add the arrow to the right hand side.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    @rowObj = row_for_index_path(indexPath)
    @reset_for = @rowObj["Name"]
    @confirm = UIAlertView.alloc.initWithTitle("Confirm Password Reset", 
                                          message:"Reset #{@reset_for}'s password?",
                                          delegate:self, 
                                          cancelButtonTitle:"Cancel", 
                                          otherButtonTitles:"Yes - Reset", nil)
    @confirm.show
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    ap "buttonIndex = #{buttonIndex}"
    case buttonIndex
    when 0
      @confirm.dismissWithClickedButtonIndex(buttonIndex, animated:true)
    when 1
      request = SFRestAPI.sharedInstance.requestForUserPasswordReset(@rowObj["Id"])
      SFRestAPI.sharedInstance.send(request, delegate: self)
    else
      @confirm.dismissWithClickedButtonIndex(buttonIndex, animated:true)
    end
  end
end
