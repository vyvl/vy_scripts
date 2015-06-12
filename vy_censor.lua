words_path = Core.GetPtokaXPath().."scripts/".."words.tbl"
allowed_profiles ={
[-1] = 0,[0] = 1,[1] = 1,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,
}
OnStartup = function()
	if loadfile(words_path) then
		dofile(words_path) -- this reads the words table from a file on disk and loads it to memory
	else
		words = {}
		SaveToFile(words_path,words,"words") -- creates a new table if it does not exist
	end
end



ChatArrival = function(user,data)
 local s,e,command,arg = string.find(data,"%b<>%s%p(%S+)%s+(.*)|$")
	if Check(user) then  
	  if command == "addword" and arg ~= nil then
		add_word(arg,words)
		Core.SendToUser(user, "The word "..arg.." will be substituted")
		return true
	   elseif command == "subword" and arg ~=nil then  	
		 local d,e,wrd,sb = string.find(arg,"(%S+) (%S+)")
		 sub_word(user,wrd,sb,words)
		 Core.SendToUser(user, "The word "..wrd.." will be substituted")
		 return true
	   elseif command =="remword" and arg ~=nil then
		 rem_word(user,arg)
		 return true
	  end
	  for i,v in pairs(words) do
		if data:find(i) then		
		data = string.gsub(data,i,v)
		Core.SendToAll(data)
		return true
		end
	  end
	end
end
OpConnected = function(user)
	SendCommands(user)
end

add_word = function (word,words)
    for i,v in pairs(words) do
      if v==word then
        return true
      end
     end    
    subt = string.sub(word,2,-2)
    x= string.len(subt)
    sub = string.gsub(word,subt,string.rep("*",x))    
	words[word] = sub
	SaveToFile(words_path,words,"words")	
end
sub_word = function (user,word,subb,words)
    for i,v in pairs(words) do
      if v==word then
        Core.SendToUser(user, "The word "..v.." exists")
        return true
      end
    end 
	words[word] = subb    
	SaveToFile(words_path,words,"words")
end

rem_word = function(user,word)
	if words[word] then
		words[word] = nil
		Core.SendToUser(user,"The word "..word.." is removed.")
		return true
	end
	Core.SendToUser(user,"The word "..word.." is already removed or unavailable.")
end
SendCommands = function(user)
	if Check(user) then
		Core.SendToUser(user,"$UserCommand 1 3 Censor\\Add Word$<%[mynick]> +addword %[line:Enter word]&#124;|")
		Core.SendToUser(user,"$UserCommand 1 3 Censor\\Substitute Word$<%[mynick]> +subword %[line:Enter word] %[line:Enter substitution string]&#124;|")
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

Check = function(user)
	if allowed_profiles[user.iProfile] == 1 then
		return true
	else
		return false
	end
end