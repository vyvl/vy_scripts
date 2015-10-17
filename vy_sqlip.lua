 sqlite3 = require("lsqlite3")
 db = sqlite3.open("iptable.sqlite3")
 
 
OnStartup = function()


	if(sqlite3 == nil) then
		Core.SendToAll("EROOR")
	else
		Core.SendToAll(sqlite3.version())
	end


db:exec[[
  CREATE TABLE test (nick varchar(50), ip varchar(50));
]]


end

OnExit = function()
	db:close()
end

UserConnected = function(user)
	del(user.sNick,user.sIP)
	login(user.sNick,user.sIP)
end

OpConnected = UserConnected
RegConnected = UserConnected

ChatArrival = function(user,data)

	local s,e,cmd,args = string.find(data,"%b<> %p(%w+)%s?(%d*)") 
	local s,e,command,arg = string.find(data,"%b<> %p(%w+)%s(.*)|")	
	if(command == "ips") then		
		if arg and not displaynicks(arg) then		
			Core.SendToUser(user,"Specified IP or Nick doesn't exist in Database")
		end
		return true
	end

end

displayall = function()
	for row in db:nrows("SELECT * FROM test") do
 		Core.SendToAll(row.nick.." "..row.ip)
	end
end

displaynicks = function(unick)	
	local found = false
	for row in db:nrows("SELECT * FROM test Where nick =".."'"..unick.."' or ip=".."'"..unick.."'") do
 		Core.SendToAll(row.nick.." "..row.ip)
 		found = true
	end
	return found
end
login = function(nick,ip)
	for row in db:nrows("SELECT * FROM test Where nick =".."'"..nick.."' and ip=".."'"..ip.."'") do
 		return nil
	end
	local stmt = db:prepare[[ 
	insert INTO test VALUES (:key, :value);
	 ]]
	stmt:bind_names{  key = nick,  value = ip    }
	stmt:step()
	stmt:reset()
end

del = function(nick,ip)
	local stmt = db:prepare[[ 
	delete from test where (nick =:key and ip =:value);
	 ]]
	stmt:bind_names{  key = nick,  value = ip    }
	stmt:step()
	stmt:reset()
end