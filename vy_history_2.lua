history = {}
op_history = {}
max_history = 300
default_history = 20
OnStartup = function()
 opchat = SetMan.GetString(24)
end
x2y = function(msg,user)
	local e,s, cmd,arg = msg:find("%b<> %p(%w+)%s?(.*)")	
	if cmd then		
		if chat_cmd[cmd] then			
			Core.SendPmToUser( user, opchat, chat_cmd[cmd](user,arg))
			return "done"
		end	
	end

	if #op_history>=max_history then
		table.remove(op_history,1)
		table.insert(op_history,"- "..os.date("[%H:%M:%S] ") ..msg)
	else
		table.insert(op_history,"- "..os.date("[%H:%M:%S] ") ..msg)		
	end	
	

end
chat_cmd = {
	history = function(user,arg)
		default_history = 20
		arg = tonumber(arg)
		if arg == nil then
				if #op_history > default_history then
					start = #op_history - default_history + 1
				else
					start = 1
				end
			else

				if #op_history > arg then
					start = #op_history - arg + 1
				else
					start = 1
				end
				-- start = 1
			end
			number_of_lines = #op_history - start + 1
			hist="- Chatroom history [showing "..number_of_lines.." lines]:"
			for i = start , #op_history do
				hist = hist .."\n".. op_history[i]
			end		
			
			return hist
	
	end
}

ChatArrival = function(user,data)
local s,e,cmd,args = string.find(data,"%b<> %p(%w+)%s?(%d*)") 
local s,e,command,arg = string.find(data,"%b<> %p(%w+)%s(.*)|")
datax = data:sub(1,-2)

if not cmd and not data:find("is kicking %S+ because:")then
	if #history>=max_history then
		table.remove(history,1)
		table.insert(history,"- "..os.date("[%H:%M:%S] ") ..datax)
	else
		table.insert(history,"- "..os.date("[%H:%M:%S] ") ..datax)
		
	end	
end	
	if cmd =="history" then
		argn = tonumber(args)
		if argn == nil then
			if #history > default_history then
				start = #history - default_history + 1
			else
				start = 1
			end
		else

			if #history > argn then
				start = #history - argn + 1
			else
				start = 1
			end
			-- start = 1
		end
		number_of_lines = #history - start + 1
		hist="- Mainchat history [showing "..number_of_lines.." lines]:"
		for i = start , #history do
			hist = hist .."\n".. history[i]
		end		
		Core.SendToNick(user.sNick,"<" .. SetMan.GetString(21) ..">\n".. hist)
		return true
	end
	if cmd == "clearhist" then
		history = {}
		Core.SendToUser(user,"History Cleared")
	end
	
	if command=="remhist" then
		for i,v in pairs(history) do
			if v==arg then
				table.remove(history,i)
				Core.SendToUser(user,"Removed line from history")
				return true
			end
		end
	end

end

ToArrival = function( user, data)
	local s, e, name = data:find( "%$To: (%S+)" )
	if name == opchat then
		local s, e, msg = data:find( "%b$$(.*)|" )		
		local rep = x2y(msg,user)
		if(rep=="done") then
			return true
		end
		
	end

end

