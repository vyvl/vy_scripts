
OnStartup = function()
	SetMan.SetMinShare(0)
end

UserConnected = function(user)
	Core.GetUserAllData(user)	
	if (user.iShareSize < 50000000000) and Client(user) then
		Core.SendToNick(user["sNick"],"Your share is below 50GB, share some data and reconnect.")
		Core.Disconnect(user)
	end
end


Client = function(user)
	Core.GetUserAllData(user)
	tag = user.sTag
	if(string.find(tag,"Gadget"))then
		return false
	end
	return true
end

