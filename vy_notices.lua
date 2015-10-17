sections_def = {
	[1] = "notices",

	[2] = "sales",

	[3] = "lost",
	
	[4] = "travel",

	[5] = "others",
}
-- serpent = dofile("serpent.lua")
--require("serpent")

notices_path = Core.GetPtokaXPath().."scripts/".."notices.tbl"
lost_path = Core.GetPtokaXPath().."scripts/".."lost.tbl"
sales_path = Core.GetPtokaXPath().."scripts/".."sales.tbl"
travel_path = Core.GetPtokaXPath().."scripts/".."sales.tbl"
others_path = Core.GetPtokaXPath().."scripts/".."others.tbl"


OnStartup = function()
	--dofile(notices_path) 

	if loadfile(notices_path) then
		notices = dofile(notices_path) 
	else
		notices = {}
		-- notices["sections"] = list
		-- notices["modify"] = category
		-- notices["loader"] = save
		-- notices["sales"] = {}
		for i,v in pairs(sections_def) do
			notices[v] = {}
		end
		save()
	end

	save()
end

ChatArrival = function(user,data)
	local s,e,cmd,arg1,arg2 = string.find(data,"%b<>%s%p(%w+)%s?(%a+)%s?(.+)|") 
	local s,e,mode,command,arg = string.find( data, "%b<> (%p)(%w+)%s?(.*)|")

	if exists(command) then
		if arg~="" then
			if type(notices[command]) == "table" then
				if mode == "-" then
					table.remove(notices[command],arg)
				else
					table.insert(notices[command],arg)
				end
				save()
			return true	
			end
		else
			Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n"..senduser(command))			
		end
	end		
	if command == "list" then
		list()
	elseif command == "category" then
		category(mode,arg)	
	elseif command == "motd" then	
		Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n"..motd())
	end
			

	-- if exists(command) then
		-- if arg~="" then
			-- if type(notices[command]) == "table" then
				-- if mode == "-" then
					-- table.remove(notices[command],arg)
				-- else
					-- table.insert(notices[command],arg)
				-- end
				-- save()
			-- elseif type(notices[command]) == "function" then
				-- value = notices[command](mode,arg)
				-- Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n"..value)
			-- end
		-- else
			-- local value
			-- if type(notices[command]) == "function" then
				-- value = notices[command]()
				-- if not value then return end
				-- Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n"..value)
			-- elseif type(notices[command]) == "table" then
				-- value = senduser(command)			
			-- end
			-- Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n"..value)
		-- end	
		-- return true		
	-- end

end

save = function()	
	Save_File(notices_path,notices,"notices")
	-- notices["loader"] = save	
	-- notices["sections"] = list
	-- notices["modify"] = category
	-- local file = io.open (notices_path , "wb")
	-- file:write(serpent.dump(notices))
	-- file:close()
end

exists = function(display)
	if notices[display] then
		return true
	end
	return false
end

	list = function()
		local response = "\n Showing sections available for adding notices\n\n"
		local index=0
		for i,v in pairs(notices) do
			if type(v)=="table" then
				index = index + 1
				response = response..index.." \t "..i.."\n"
			end
		end
		return response
	end

	category = function(mode,arg)
		if mode == "-" then
			if(notices[arg]) then
				table.remove(notices,arg)
				save()
				return "Removed the category "..arg.." successfully"
			else
				return "Category "..arg.." not found"
			end
		else
			if(notices[arg]) then			
				return "Category "..arg.." exists"
			else
				notices[arg] = {}
				save()
				return "Category "..arg.." added"
			end
		end
		
	end

	senduser = function(command)
		local response = "\n\n\n"..string.rep("=",50)..string.rep("<",3)..string.upper(command)..string.rep(">",3)..string.rep("=",50).."\n\n\n"
		for i,v in pairs(notices[command]) do
			response = response..i.."  "..v.."\n\n"
		end
		return response
	end

	motd = function()
		local reply = "INITIAL TEXT\n\n\n"
		
	
		for i,v in pairs(notices) do
			reply = reply..senduser(i).."\n\n"
		end
		
		return reply
		
	end
Save_Serialize = function(tTable, sTableName, hFile, sTab) -- copied this function code online
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n" )
	for key, value in pairs(tTable) do
		local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key)
		if(type(value) == "table") then
			Save_Serialize(value, sKey, hFile, sTab.."\t")
		else
			local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value)
			hFile:write( sTab.."\t"..sKey.." = "..sValue)
		end
		hFile:write(",\n")
	end
	hFile:write( sTab.."}")
end

Save_File = function(file,table, tablename ) -- copied this function code online
	local hFile = io.open (file , "wb")
	Save_Serialize(table, tablename, hFile)
	hFile:flush() hFile:close()
	collectgarbage("collect")
end