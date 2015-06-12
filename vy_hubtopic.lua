k = 0
topic_path = Core.GetPtokaXPath().."scripts/".."topics.tbl"
allowed_profiles ={
[-1] = 0,[0] = 1,[1] = 1,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,
}



OnStartup = function()

	if loadfile(topic_path) then
		dofile(topic_path) -- this reads the ip table from a file on disk and loads it to memory
	else
		topics = {}
		SaveToFile(topic_path,topics,"topics") -- creates a new table if it does not exist
	end
	interval = TmrMan.AddTimer(5*60000,Moving)
end	


ChatArrival = function(user,data)
local s,e,command,arg = string.find( data, "%b<> %p(%w+)%s?(.*)|$")
if command == "addtopic" and allowed_profiles[user.iProfile] ==1  then
	for i,v in pairs(topics) do
		if v== arg then
			Core.SendToUser(user,"Topic Exists")
			return true
		end
	end
	table.insert(topics,arg)
	SaveToFile(topic_path,topics,"topics")
	Core.SendToUser(user,"Topic added")
	Change(arg)
	return true
elseif command == "remtopic"  and allowed_profiles[user.iProfile] ==1 then
	arg = tonumber(arg)
	if topics[arg] then	
		table.remove(topics,arg)
		SaveToFile(topic_path,topics,"topics")
		Core.SendToUser(user,"Topic Removed")
		return true
	else
	Core.SendToUser(user,"Topic not found")
		return true
	end	
elseif command =="clrtopic" and allowed_profiles[user.iProfile] ==1 then
	topics = {}
	SaveToFile(topic_path,topics,"topics")
elseif command=="showtopic" and allowed_profiles[user.iProfile] ==1 then
	str = "\n"
	for i,v in pairs(topics) do
		str = str..i.."\t"..v.."\n"
	end
	Core.SendToUser(user,str)
	return true
end		
end
	


Change = function(arg)
if not arg then
	return true
end
SetMan.SetString(10,arg)
end

Moving = function()

if k < #topics then
k = k+1
else
k =1 
end
Change(topics[k])
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