
ip_path = Core.GetPtokaXPath().."scripts/".."ip.tbl"
nick_path = Core.GetPtokaXPath().."scripts/".."nick.tbl"
bhawan_path = Core.GetPtokaXPath().."scripts/".."ip_bhawan.tbl"
allowed_profiles ={
[-1] = 0,[0] = 1,[1] = 1,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,
}
OnStartup = function()

	if loadfile(ip_path) then
		dofile(ip_path) -- this reads the ip table from a file on disk and loads it to memory
	else
		ip = {}
		SaveToFile(ip_path,ip,"ip") -- creates a new table if it does not exist
	end
	if loadfile(nick_path) then
		dofile(nick_path) -- this reads the nick table from a file on disk and loads it to memory
	else
		nick = {}
		SaveToFile(nick_path,nick,"nick") -- creates a new table if it does not exist
	end
	if loadfile(bhawan_path) then
		dofile(bhawan_path) -- this reads the ip table from a file on disk and loads it to memory
	else
		ip_bhawan = {}
		SaveToFile(bhawan_path,ip_bhawan,"ip_bhawan") -- creates a new table if it does not exist
	end 
end

UserConnected = function(user)
	Core.SendToAll(user.sNick.."Entered the Hub")
	temp_nick = user.sNick
	temp_ip = user.sIP
	Check(ip,temp_ip,temp_nick,"ip","nick")
	Check(nick,temp_nick,temp_ip,"nick","ip")
	if Checkprof(user) then
	SendCommands(user)
	end
end

OpConnected = UserConnected
RegConnected = UserConnected

ChatArrival = function(user,data)
local s,e,command,arg = string.find( data, "%b<> %p(%w+) (%S+)%s?|$")
if Checkprof(user) then
	if command == "ip" and arg ~= nil then
		reply = "\n\tip: "..arg.."  \t"..Bhawan(arg).."\n"
		if ip[arg] then
			for i,v in pairs(ip[arg]) do
				reply=reply.."\tNick: "..v.."\n"
			end
		else
			reply = "Specified IP address is not available in database"	
		end
		
		Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n"..reply)
		--Core.SendToNick(user.sNick,"<" .. SetMan.GetString(21) ..">\n"..reply)
		return true
	elseif command == "nick" and arg ~= nil then	
		reply = "\n\tNick: "..arg.."\n"
		if nick[arg] then
			for i,v in pairs(nick[arg]) do
				reply=reply.."\tIp: "..v.."  \t"..Bhawan(v).."\n"
			end
		else
			reply = "Specified Nick is not available in database"	
		end
		Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n"..reply)
		--Core.SendToNick(user.sNick,"<" .. SetMan.GetString(21) ..">\n"..reply)
		return true
	end
end
end


Check = function(table_name,parent,child,para1,para2)
	
	if table_name[parent] and table_name ~= nil then
			
		for i,v in pairs(table_name[parent]) do
			if child == v then
				return true
			end
		end
		table.insert(table_name[parent],child)
		if para1 == "ip" then
			SaveToFile(ip_path,ip,"ip")
		else
			SaveToFile(nick_path,nick,"nick")
		end	
		return true
			
	end
	table_name[parent] = {}
	table.insert(table_name[parent],child)	
	if para1 == "ip" then
		SaveToFile(ip_path,ip,"ip")
	else
		SaveToFile(nick_path,nick,"nick")
	end

	
end

SendCommands = function(user)
	if Checkprof(user) then
		Core.SendToUser(user,"$UserCommand 1 3 IP\\Search IP$<%[mynick]> +ip %[line:Enter IP]&#124;|")
		Core.SendToUser(user,"$UserCommand 1 3 IP\\Search Nick$<%[mynick]> +nick %[line:Enter Nick]&#124;|")
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

Checkprof = function(user)
	if allowed_profiles[user.iProfile] == 1 then
		return true
	else
		return false
	end
end
Bhawan = function(ips)
local e,s,rg,subnet = ips:find(".-%.(.-)%.(.-)%..-")
if(rg=="17") then
if not ip_bhawan[subnet] then
return ""
end
return ip_bhawan[subnet].." Bhawan"
end
return ""

end