class SFRestDelegate

def request(request, didLoadResponse: jsonResponse)
		ap "Executing Request:DidLoadResponse"
		if jsonResponse.keys.include?('NewPassword')
			# alert = UIAlertView.alloc.init
			# alert.message = "Password Reset issued for: #{@reset_for}"
			# @reset_for = nil
			# alert.addButtonWithTitle "OK"
			# alert.show
			# refresh
		else
			incoming = jsonResponse.objectForKey("records")
			@data = reindex_table_data(incoming)
		end
	end

	# def reindex_table_data(incoming)
	# 	tmp = {}
	# 	("A".."Z").each do |l|
	# 		tmp[l] = incoming.select {|i| i["LastName"].starts_with? l}
	# 	end
	# 	tmp
	# end

	def request(request, didFailLoadWithError: error)
		App.alert("Salesforce API request failed with error: #{error}")
		ap "Request:DidFailLoadWithError: #{error}"
	end

	def requestDidCancelLoad(request)
		ap "Request:requestDidCancelLoad: #{request}"
	end

	def requestDidTimeout(request)
		App.alert("Salesforce API request Timed out! Wifi or Cellular Data Required")
		ap "Request:requestDidTimeout: #{request}"
	end

end