--[[

    HubList 1.0 LUA 5.1x [API 2]  
    
    Network Hub Pinger and Hublist
    
    -Checks online status of hubs, using PXLuaSocket extension lib.
    -Not a true hublist pinger, merely checks if hub is online/offline
    -Hubs table saved to file for hub/script restart.
    -Commands: Hublist, Add Hub, Edit Hub & Remove Hub
    
    
    ***Note requires PxLuaSocket 2.0.2, dowload here:
    http://www.czdc.org/PtokaX/Libs-0.3.6.0d/PXLuaSocket-2.0.2.7z
    extract to PtokaX\script\libs
    

]]


local socket = require("socket")

hubs_path = Core.GetPtokaXPath().."scripts/".."hubs.tbl"

allowed_profiles ={
    [-1] = 0,[0] = 1,[1] = 1,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,
}

OnStartup = function()
    if loadfile(hubs_path) then
        dofile(hubs_path) -- this reads the hubs table from a file on disk and loads it to memory
    else
        hubs = {}
        Save_File(hubs_path,hubs,"hubs") -- creates a new table if it does not exist
    end
	interval = TmrMan.AddTimer(1*60000,Check)
end

OnTimer = function(interval)
	if interval then
		Check()
	end
end

ChatArrival = function(user,data)
    local s,e,cmd,ip,port,owner,name = string.find(data,"%b<>%s%p(%w+)%s(.*):(%d-)%s(%S+)%s(.*)|")
    local s,e,command,arg = string.find(data,"%b<> %p(%w+)%s?(.*)|")
    def_name = name
    if cmd=="addhub" and allowed_profiles[user.iProfile] ==1 then
		hubs[name] ={}
        if ping(ip,tonumber(port)) then
           hubs[name]["status"] = "Online"
        else
            hubs[name]["status"] = "Offline"
        end
			
            hubs[name]["ip"] = ip
            hubs[name]["port"] = port
            hubs[name]["owner"] = owner
            Core.SendToUser(user,"Hub "..name.." is added to hublist")
			Save_File(hubs_path,hubs,"hubs")
        return true
    end
    if command=="hublist" then
        pretext = [[

	                           -   Current running hubs hosted on BITS LAN   -

        ===========================================================================================================
                Name                 	          IP	           	              		Owner/Admin	        	Status
        ___________________________________________________________________________________________________________
        
        ]]        
                posttext = [[

        ___________________________________________________________________________________________________________
        (Just click on the link to connect)
        ===========================================================================================================
        PM V10let with the HubName and IP if you know about any other running hubs.
        Please send entries that are running for more than 1 week. Do not bug Ops/Admins in PM.
        ===========================================================================================================
		]]
        hub_text= ""
        for i,v in pairs(hubs) do
			ip = 'dchub://'..v["ip"]
			hub_text = hub_text .. string.format("\t%-20s\tdchub://%s:%s\t\t%-20s\t\t%s\n\n",i,v["ip"],v["port"],v["owner"],v["status"])
         -- hub_text = hub_text .. string.format("\t%s\t\tdchub://%s:%s\t\t%-20s\t\t%s\n\n",i,v["ip"],v["port"],v["owner"],v["status"])
        end
        Core.SendToUser(user,"<[DeZire-BOT]> "..pretext..hub_text..posttext.."|")
        return true
    end
    if command == "remhub" and allowed_profiles[user.iProfile] ==1 then
        if hubs[arg] then
            hubs[arg] = nil
            Core.SendToUser(user,"Hub removed Successfully")
			Save_File(hubs_path,hubs,"hubs")
            return true
        end
        Core.SendToUser(user,"Hub not found")
		Save_File(hubs_path,hubs,"hubs")
        return true
    end

end

function bODD(x)
       return x ~= math.floor(x / 2) * 2
end

function bitwise(x, y, bw)
       local c, p = 0, 1
       while x > 0 or y > 0 do
           if bw == "xor" then
               if (bODD(x) and not bODD(y)) or (bODD(y) and not bODD(x)) then
                       c = c + p
               end
           elseif bw == "and" then
               if bODD(x) and bODD(y) then
                       c = c + p
               end
           elseif bw == "or" then
               if bODD(x) or bODD(y) then
                       c = c + p
               end
           end
           x = math.floor(x / 2)
           y = math.floor(y / 2)
           p = p * 2
       end
       return c
end

function nibbleswap(bits)
    return bitwise(bitwise(bits*(2^4),240,"and"),bitwise(math.floor(bits/(2^4)),15,"and"),"or")
end

function lock2key(lock)
    local key = {}
    table.insert(key,bitwise(bitwise(bitwise(string.byte(lock,1),string.byte(lock,-1),"xor"),string.byte(lock,-2),"xor"),5,"xor"))
    for i=2,string.len(lock),1 do
        table.insert(key,bitwise(string.byte(lock,i),string.byte(lock,i - 1),"xor"))
    end
    local g = {["5"]=1,["0"]=1,["36"]=1,["96"]=1,["124"]=1,["126"]=1}
    for i=1,table.getn(key),1 do
        local b = nibbleswap(rawget(key,i)) 
        rawset(key,i,(g[tostring(b)] and string.format("/%%DCN%03d%%/",b) or string.char(b)))
    end
    return table.concat(key)
end

Check = function()
	--Core.SendToAll("Timer Activated")
	for i,v in pairs(hubs) do
		if ping(v["ip"],tonumber(v["port"])) then
           hubs[i]["status"] = "Online"
        else
            hubs[i]["status"] = "Offline"
        end
	end
	Save_File(hubs_path,hubs,"hubs")
end
ping = function(ip,port)
	if ip =="127.0.0.1" or ip =="172.17.32.32" then
	return true
	end
    udp_serv = socket.tcp()
	udp_serv:settimeout(1)
    udp_serv:connect(ip,port)
    c = ""
    while true do
        k = udp_serv:receive(1)
        
        if not k then
            return false
        end
		c = c .. k
        if k == "|" then
             return true
        end
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