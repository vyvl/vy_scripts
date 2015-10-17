

ChatArrival = function(user,data)

	local s,e,cmd,args = string.find( data, "%b<> %p(%S+)%s?(.*)|$")
	--cmd = string.lower(cmd)
	if cmd then
		cmd = string.lower(cmd)
	else
		return	
	end
	for i,v in pairs(commands) do
		if i==cmd then
			v(user,args)
			return true
		end
	end

end



commands = {
["profmsg"] = 

	function(user,args)	
		local e,s,num,message = string.find(args,"%s*(%d+)%s*(.+)")
		if num and message then
			Core.SendToProfile(tonumber(num),"<"..user,sNick.."> "..message)
		else
			Core.SendToUser(user,"Check the arguments, syntax: +profmsg num message, example +profmsg 1 Hello --Will send Hello to All Masters")	
		end	
	end ,
	
["profpm"] = 

	function(user,args)	
		local e,s,num,message = string.find(args,"%s*(%d+)%s*(.+)")
		if num and message then
			Core.SendPmToProfile(tonumber(num),user.sNick ,message)
		else
			Core.SendToUser(user,"Check the arguments, syntax: +profmsg num message, example +profmsg 1 Hello --Will send Hello to All Masters")	
		end	
	end ,
		
["password"] =

	function(user,args)
		local e,s,pass = string.find(args,"%s*(%S+)")
		RegMan.ChangeReg(user.sNick,pass,user.iProfile)	
	end,

["changeprof"] =

	function(user,args)
		if not (user.iProfile ~= 0 and user.iProfile~=1) then
			local e,s,nick,number = string.find(args,"%s*(%S+)%s*(%d+)")
			RegMan.ChangeReg(nick,nil,tonumber(number))	
		else
			Core.SendToUser(user,"You don't have the permission to use this command")
		end	
	end	,
	["status"] =
	 function(user,args)
	 	if user.iProfile ~= 0 and user.iProfile~=1 then
	 		return
	 	end
	 	local profs = ProfMan.GetProfiles()			
		for i,v in pairs(profs) do
			local users = Core.GetOnlineUsers(v["iProfileNumber"])
			local registered = RegMan.GetRegsByProfile(v["iProfileNumber"])	
			Core.SendToUser(user,"Users online ("..v["sProfileName"]..") -- "..table.getn(users).." / "..table.getn(registered))		
		end
		local unreg = table.getn(Core.GetOnlineUsers(-1))
		Core.SendToUser(user,"Users online (UnReg) -- "..unreg)
		
	
	end	,
	["profiles"] = 
	function(user,args)
		local profs = ProfMan.GetProfiles()	
		for i,v in pairs(profs) do
			Core.SendToUser(user,v["sProfileName"].."\t\t"..tostring(v["iProfileNumber"]))
		end
		Core.SendToUser(user, "For unreg use -1 as profile number")
	end,
	
	["kickunreg"] = 
	function(user,args)
		local users = Core.GetOnlineUsers(-1)
		for i,v in pairs(users) do
			Core.Disconnect(v)
		end
	end,
	["regonly"] = 
	function(user,args)
		if user.iProfile ~= 0 and user.iProfile~=1 then
	 		Core.SendToUser("Check permissions")
	 		return
	 	end
		local e,s,val = string.find(args,"%s*(%d+)")
				val = tonumber(val)
		if val==0 then
			SetMan.SetBool(SetMan.tBooleans.RegOnly,false)
		else
			SetMan.SetBool(SetMan.tBooleans.RegOnly,true)
		end
	end
	
}