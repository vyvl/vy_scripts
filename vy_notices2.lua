notices_path = Core.GetPtokaXPath().."scripts/".."notices.tbl"

OnStartup = function() 

	if loadfile(notices_path) then
			dofile(notices_path) 
	else
			notices = {}			
	end 
	if not notices then
		notices = {}		
	end	
end 

OnExit = function()

Save_File(notices_path,notices,"notices")

end

Display = function(sec)
	local s = "\nDisplaying all notices under the section "..sec.."\n\n"
	for i,v in pairs(notices[sec]) do
		s = s.."\n"..i.."\t"..v
	end
	return s
end

ChatArrival = function(user,data) 

	local s,e,cmd,arg1,arg2 = string.find(data,"%b<>%s%p(%w+)%s?(%a+)%s?(.+)|")
	local e,s,command = string.find(data,"%b<>%s%p(%w+)%s*|")
	if(cmd == "notices") then 
	
		if(arg1=="sections") then
			if(notices[arg2]) then
				Core.SendToUser(user,"The section "..arg2.. " exists" )	
			else
				notices[arg2] = {}
				Core.SendToUser(user,"The section "..arg2.. " is added" )	
			end
			return true
		end

		if(notices[arg1]) then
			table.insert(notices[arg1],arg2)
			Core.SendToUser(user,"Notice added successfully" )
		else 
			Core.SendToUser(user,"The section "..arg1.. " is not found" )	
		end	 
		return true
	end
	
	if(cmd == "del") then
		if(notices[arg1]) then
			table.remove(notices[arg1],arg2)
			Core.SendToUser(user,"The notice is removed" )	
		else
			Core.SendToUser(user,"The section "..arg1.. " is not found" )	
		end
		return true
	end
	
	if(notices[command]) then
		local s = Display(command)
		Core.SendToUser(user,s)
		return true
	end 
	
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