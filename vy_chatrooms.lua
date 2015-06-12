max_history = 150

OnStartup = function()

--To load previously stores chatrooms.
	if loadfile("rooms.tbl") then
		dofile("rooms.tbl") 
	else
		rooms = {}
		SaveToFile("rooms.tbl",rooms,"rooms")
	end
-- Register the rooms as BOTS to the hub	
	for i,v in pairs(rooms) do
		Core.RegBot( i, "", "", true )
	end
	chat_perm = {[-1] = 0,[0] = 1,[1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,}
end

UserConnected = function(user)
	SendCommands(user)
	pn = user.iProfile
	for i,v in pairs(rooms) do
		if v["profile"] == nil then --If the room doesnt have any profile permissions, it will add Masters as users.
			v["profile"] = {}
			v["profile"][0] = true
			SaveToFile("rooms.tbl",rooms,"rooms")
		end
		
		if v["profile"][pn] then -- If the user profile meets the room requirements, add the user to the room.
			if not v["users"][user.sNick] then
				v["users"][user.sNick] = true				
			end				
			SaveToFile("rooms.tbl",rooms,"rooms")
		end
	end
end
OpConnected = UserConnected
RegConnected = UserConnected

	
ChatArrival = function(user,data)
local s,e,cmd,arg1,arg2 = string.find(data,"%b<>%s%p(%w+)%s(%S+)%s(.*)|") 
local s,e,command,arg = string.find(data,"%b<>%s%p(%w+)%s(%S+)|") 

if cmd == "addroom" and chat_perm[user.iProfile]==1 then
	--Core.SendToUser(user,"x"..arg2.."x")
	
	if rooms[arg1] then -- Check if a room with that name exists
		Core.SendToUser(user, "ChatRoom exists already")
		return true	
	end
	rooms[arg1] = {}
	rooms[arg1]["users"] = {}
	rooms[arg1]["profile"] = {}
	rooms[arg1]["history"] = {}
	if arg2 then
		for arg2x in string.gmatch(arg2,"%S+") do 
		if not ProfMan.GetProfile(arg2x) then -- if the arguments doesnt represent a profile => they are nicks
			--Core.SendToUser(user, "Inside no prof")
			if rooms[arg1]["users"][arg2x] then -- check if nick exists already
				Core.SendToUser(user,"User "..arg2x.." exists|")				
				--return true
			end
			rooms[arg1]["users"][arg2x] = true -- add the nick to chatroom 
			Core.SendPmToNick( arg2x, arg1, "Welcome to Chatroom "..arg1 .. " |" )			
			SaveToFile("rooms.tbl",rooms,"rooms")
			
		else
			pf = ProfMan.GetProfile(arg2) -- if argument is name of a profile
			--Core.SendToUser(user, "Inside no prof")
			rooms[arg1]["profile"][pf["iProfileNumber"]] = true
			pf_users = Core.GetOnlineUsers(pf["iProfileNumber"])
			for i,v in pairs(pf_users) do
		--		rooms[arg1]["users"][v.sNick] = true
				Core.SendPmToUser( v, arg1, "Welcome to Chatroom "..arg1 .. " |" )				
			end
			SaveToFile("rooms.tbl",rooms,"rooms")
		--	return true
		end
end		
	else
		rooms[arg1]["users"] = {}
		rooms[arg1]["history"] = {}
	end
	
	Core.RegBot( arg1, "", "", true )	
	SaveToFile("rooms.tbl",rooms,"rooms")
	Core.SendToUser(user, "ChatRoom Created")
	return true
	
end	

if cmd == "adduser" and (rooms[arg1]["users"][user.sNick] and chat_perm[user.iProfile]) then

	if not rooms[arg1] then
		Core.SendToUser(user, "ChatRoom doesn't exist")
		return true
	else
	for arg2 in string.gmatch(arg2,"(%S+)") do
		if not ProfMan.GetProfile(arg2) then
			
				if rooms[arg1]["users"][arg2] then
					Core.SendPmToUser( user, arg1, "The User "..arg2.." exists\n" )
				else
					rooms[arg1]["users"][arg2] = true
					Core.SendToUser(user,"User "..arg2.." is added to the room "..arg1)
									
				SaveToFile("rooms.tbl",rooms,"rooms")
			end	
			SaveToFile("rooms.tbl",rooms,"rooms")
			return	true
		else
			pf = ProfMan.GetProfile(arg2)
			rooms[arg1]["profile"][pf["iProfileNumber"]] = true
			pf_users = Core.GetOnlineUsers(pf["iProfileNumber"])
			for i,v in pairs(pf_users) do
				rooms[arg1]["users"][v.sNick] = true
			end
			SaveToFile("rooms.tbl",rooms,"rooms")
			return	true
		end
	end	
	return true
	end
return true	
end
if cmd == "remuser" and chat_perm[user.iProfile] then
		--Core.SendToUser(user,"x"..arg2.."x")
	if not rooms[arg1] then
		Core.SendToUser(user, "ChatRoom doesn't exist")
		return true
	else
		if not ProfMan.GetProfile(arg2) then
		for i,v in pairs(rooms[arg1]["users"]) do
			if arg2 == v then
				rooms[arg1]["users"][i] = nil
			end
		end
			SaveToFile("rooms.tbl",rooms,"rooms")
		else
			pf = ProfMan.GetProfile(arg2)
			pf_users = Core.GetOnlineUsers(pf["iProfileNumber"])
			for i,v in pairs(pf_users) do
				for j,k in pairs(rooms[arg1]["users"]) do
					if k == v.sNick then
						rooms[arg1]["users"][j] = nil
					end			
				end
			end
			SaveToFile("rooms.tbl",rooms,"rooms")
		end
	return true
	end
end	

if command=="delroom" and chat_perm[user.iProfile] then
	if not rooms[arg] then
		Core.SendToUser(user,"ChatRoom not found")
	else
		rooms[arg] = nil
		Core.UnregBot( arg)
		SaveToFile("rooms.tbl",rooms,"rooms")
		Core.SendToUser(user,"ChatRoom "..arg.." Removed")
	end
	return true
end
end
ToArrival = function( user, Message )
	
	local s, e, room = Message:find( "%$To: (%S+)" )
	if not rooms[room]  then
		return false
		else
		
		local s, e, msg = Message:find( "%b$$(.*)|" )
		local e,s, cmd,arg = msg:find("%b<> %p(%w+)%s?(.*)")
	
		if cmd then
			if def_cmd[cmd] then
				def_cmd[cmd](room,user,arg)
				return true
			end
		end
	end	
	
	if rooms[room]["users"][user.sNick]  then
		local s, e, msg = Message:find( "%b$$(.*)|" )			
		Core.SendToNick(user.sNick, "$To: "..user.sNick.." From: "..room.." $".."Test".."|")
		Add_To_History(room,msg,user)
		SendToRoom( user, room, msg )
		return true
	end
	if rooms[room]["profile"][user.iProfile] then
		local s, e, msg = Message:find( "%b$$(.*)|" )
		--Core.SendToNick(user.sNick, "$To: "..user.sNick.." From: "..room.." $".."Test".."|")
		Add_To_History(room,msg,user)
		SendToRoom( user, room, msg )
		return true
	end
Core.SendPmToUser( user, room, "You don't have access to this ChatRoom.|" )
	
end

Add_To_History = function(room,msg,user)
	local e,s, cmd,arg = msg:find("%b<> %p(%w+)%s?(.*)")
	
	if cmd then
		--Core.SendPmToUser( user, room,tostring(cmd))
		if chat_cmd[cmd] then
			--Core.SendPmToUser( user, room,cmd)
			Core.SendPmToUser( user, room, chat_cmd[cmd](room,user,arg))
			return true
			--Core.SendToNick(user.sNick, "$To: "..user.sNick.." From: "..room.." $"..chat_cmd[cmd](room,user,arg).."|")
			--Core.SendPmToUser( room, user, chat_cmd[cmd](room,user,arg)  )
		end	
	end

	if #rooms[room]["history"]>=max_history then
		table.remove(rooms[room]["history"],1)
		table.insert(rooms[room]["history"],"- "..os.date("[%H:%M:%S] ") ..msg)
	else
		table.insert(rooms[room]["history"],"- "..os.date("[%H:%M:%S] ") ..msg)		
	end	
	SaveToFile("rooms.tbl",rooms,"rooms")

end
chat_cmd ={
history = function(room,user,arg)
	default_history = 20
	if argn == nil then
			if #rooms[room]["history"] > default_history then
				start = #rooms[room]["history"] - default_history + 1
			else
				start = 1
			end
		else

			if #rooms[room]["history"] > arg then
				start = #rooms[room]["history"] - arg + 1
			else
				start = 1
			end
			-- start = 1
		end
		number_of_lines = #rooms[room]["history"] - start + 1
		hist="- Chatroom history [showing "..number_of_lines.." lines]:"
		for i = start , #rooms[room]["history"] do
			hist = hist .."\n".. rooms[room]["history"][i]
		end		
		
		return hist
	
end,

invite = function(room,user,arg)
	if arg then
		if rooms[room]["users"][arg] then
			return "User "..arg.." already exists"	
		end
		if rooms[room]["lock"] then
			return ""
		end
		rooms[room]["users"][arg] = true
		Core.SendPmToNick( arg, room, "Welcome to Chatroom"..room .. " |" )	
		return "Invited "..arg.." To Chatroom"	
	
	end
		return "Check syntax : +invite <nick>"
end,

lock = function(room,user,arg)
	if chat_perm[user.iProfile]==1 and arg=="on" then
		rooms[room]["lock"] = true
		return "Room locked"
	end
	if chat_perm[user.iProfile]==1 and arg=="off" then
		rooms[room]["lock"] = nil
		return "Room unlocked"
	end
	return "Check Syntax and Perms"
end,
leave = function(room,user,arg)
rooms[room]["users"][user.sNick] = nil	
	SendToRoom(room,room,user.sNick.." left the room")
	return "You will be removed from the room incase of noprofile" 
end

}

def_cmd = {
join = function(room,user,arg)
	if rooms[room]["lock"] then
		Core.SendPmToNick( user.sNick, room, "This room is locked, ask a member inside the room to invite you")
		return true
	else
		if rooms[room]["users"][user.sNick] then
			Core.SendPmToNick( user.sNick, room, "You have access to the room already"	)
			return true
		end
		rooms[room]["users"][user.sNick] = true
		Core.SendPmToNick( user.sNick, room, "Welcome to Chatroom "..room .. " |" )	
		SendToRoom(room,room,user.sNick.." joined the room")	
	end
end,

}
SendToRoom = function( user, room, message )
-- To forward message to all users in chatroom
	for i,v in pairs(rooms[room]["users"]) do
		if user.sNick ~= i then
		Core.SendToNick(i, "$To: "..i.." From: "..room.." $"..message.."|")
		end
	end	
			
-- To forward messgae to all users with profile permissions			
	for i,v in pairs (rooms[room]["profile"]) do
		pf_users = Core.GetOnlineUsers(i)
		for i,v in pairs(pf_users) do		
			if not rooms[room]["users"][v.sNick] then
				if user.sNick ~= v.sNick then
					Core.SendToNick(v.sNick, "$To: "..v.sNick.." From: "..room.." $"..message.."|")
				end
			end	
		end
	end

	return true
	
end

SendCommands = function(user)
if chat_perm[user.iProfile]==1 then
Core.SendToUser(user,"$UserCommand 1 1 ChatRooms\\Add Room$<%[mynick]> +addroom %[line:Name of the Room] %[line:Enter a profile name or user Nick]&#124;|")
Core.SendToUser(user,"$UserCommand 1 1 ChatRooms\\Add User$<%[mynick]> +adduser %[line:Enter name of the room] %[line:Enter user Nick]&#124;|")
Core.SendToUser(user,"$UserCommand 1 1 ChatRooms\\Remove User$<%[mynick]> +remuser %[line:Enter name of the room] %[line:Enter user Nick]&#124;|")
Core.SendToUser(user,"$UserCommand 1 1 ChatRooms\\Remove Room$<%[mynick]> +delroom %[line:Enter name of the room]&#124;|")
end
end
Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end