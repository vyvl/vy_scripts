 sqlite3 = require("lsqlite3")
 db = sqlite3.open("regtable.sqlite3")
 
 
 OnStartup = function()



db:exec[[
  CREATE TABLE Reg (nick varchar(50), password varchar(50), profile varchar(50));
]]

	local nicks = RegMan.GetRegs() 			
	
	for i,v in pairs(nicks) do
		local nick = v
		AddToSQL(nick["sNick"], nick["sPassword"] , ProfMan.GetProfile(nick[ 'iProfile'])["sProfileName"])
	end

end
 
OnExit = function()
	db:close()
end

AddToSQL = function(nick,pass,profile) 

	local stmt = db:prepare[[ 
	insert INTO Reg VALUES (:key, :value, :prof);
	 ]]
	stmt:bind_names{  key = nick,  value = pass, prof = profile   }
	stmt:step()
	stmt:reset()
end