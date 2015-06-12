UserConnected = function(user)
	Core.GetUserData(user,0)
	if user.sMode == "A" then
		Core.Redirect(user, "172.17.32.32", "To DeZire")
	else
	
	str = "settings> connection settings ; Untick auto detect incoming connection type; Select active/direct (1st radio button). Restart your client.\nIncase you have any problems with active mode you can contact an Operator and he will add you as an exception\nWatch this magnet:?xt=urn:tree:tiger:LSSXFFTKDEHNP6TBJSX6VVANA75O7IUPLWCHRNI&xl=21138360&dn=DC%2B%2B+for+Dummies+by+Pilani+Pirates.mp4"
		Core.SendToUser(user,"You are in passive mode currently. Please change your mode to active and reconnect. To change to active mode see help below.\n"..str)
		Core.Redirect(user, "172.17.20.175", "Change to Passive Mode to Connect To DeZire")
		
	end	
end
