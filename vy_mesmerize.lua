mesmerize_path = Core.GetPtokaXPath().."scripts/".."mesmerize.tbl"

OnStartup = function()
	if loadfile(mesmerize_path) then
		dofile(mesmerize_path) -- this reads the words table from a file on disk and loads it to memory
	else
		mesmerize = {}
		SaveToFile(mesmerize_path,mesmerize,"mesmerize") -- creates a new table if it does not exist
	end
end

ChatArrival = function(user,data)
	local s,e,command,arg = string.find( data, "%b<> %p(%w+) (%S+)|$")
	local s,e,cmd,arg1,arg2 = string.find( data, '%b<> %p(%w+) "(.-)" "(.-)"|$')
	
	
	
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