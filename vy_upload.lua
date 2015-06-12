genre_list = {
	[1] = "movies",

	[2] = "series",

	[3] = "games",

	[4] = "apps",

	[5] = "music",

	[6] = "others",
}     -- Add new genres manually to the table
upload_perm = {[-1] = 1,[0] = 1,[1] = 1,[2] = 1,[3] = 1,[4] = 1,[5] = 1,[6] = 1,}
uploads_path = Core.GetPtokaXPath().."scripts/".."uploads.tbl"
timer = TmrMan.AddTimer(12*(60*60000))
days_to_store = 3
OnStartup = function()


	if loadfile(uploads_path) then
		dofile(uploads_path) -- this reads the uploads table from a file on disk and loads it to memory
	else
		uploads = {}
		Save_File(uploads_path,uploads,"uploads") -- creates a new table if it does not exist
	end
end

ChatArrival = function(user,data)
local s,e,code,genre,release = string.find( data, "%b<> %p(%w+)%s(%a+)%s(.+)|$") -- +upload command
local s,e,coder = string.find( data, "%b<> %p(%w+)|$") -- +uploads command
local s,e,command,arg = string.find( data, "%b<> %p(%w+) (%S+)|$") -- +clean command
	if (code=="upload" or code =="u") and upload_perm[user.iProfile] ==1 then
	
		if not release then
			Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n".. "Use: +upload <genre> <magnetlink>")
		end
		if genre == "rem" then -- to remove a upload from the uploads section
			found = nil
			for dates,genres in pairs(uploads) do
				for u_genre,u_uploads in pairs(genres) do
					for id,details in pairs(u_uploads) do
						if details["Magnet"] == release  then
							table.remove(u_uploads,id)							
							Save_File(uploads_path,uploads,"uploads")
							Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n".."Removed the upload successfully")
							Write_to_uploads()
							return true
						end
					end
				end
			end
			if not found then
				Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n".."Upload not available")  -- if the specified upload doesn't exist in uploads
				return true
			end
		end
		local found = nil
		for dates,genre_list in pairs(uploads) do
			for genre_thing,upload_by_genre in pairs(genre_list) do
				for id,details in pairs(upload_by_genre) do
					if details["Magnet"] == release  then
						if genre_thing == genre then
							Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n".."Already in Uploads") -- to prevent duplicate uploads
							return true
							
						else 
							for index,genre_test in pairs(genre_list) do
								if genre==genre_test then
									found = 1
									table.insert(genre_list["genre_thing"],details)
									table.remove(upload_by_genre,id)															
									Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n".."Modified the Genre") -- to modify the genre of existing uploads
									Save_File(uploads_path,uploads,"uploads")
									Write_to_uploads()
									return true
								end
							end	
							if not found then
								Core.SendToUser(user,"<" .. SetMan.GetString(21) ..">\n".."Specify correct Genre") -- if the specified genre doesn't exist in genre table
							end
							return true
						end
					end	
				end
			end	
		end	
		
		for index,genre_test in pairs(genre_list) do
			if genre==genre_test then

				found = 1
				upload_date = os.date("%d %b")
				uploaded = {["Magnet"] = release,["Uploader"] = user.sNick,}
				if uploads[upload_date] then
					if not uploads[upload_date][genre] then
						uploads[upload_date][genre]={}
					end
					table.insert(uploads[upload_date][genre],uploaded)	
				else
					uploads[upload_date] = {}
					uploads[upload_date][genre]={}
					table.insert(uploads[upload_date][genre],uploaded)	
					
				end		
				--table.insert(uploads,uploaded) -- Inserting into uploads
				Save_File(uploads_path,uploads,"uploads")
				--Core.SendToAll("genre found in "..index.." ".."genre_test")				
				Write_to_uploads()
				Core.SendToAll("<" .. SetMan.GetString(21) ..">  "..user.sNick.." uploaded "..release .. "  under ".. genre)
				return true
			end
		end

		
		if not found then
			Core.SendToUser(user, "<" .. SetMan.GetString(21) ..">\n".."Check genre")  -- if the specified genre does'nt exist in genre table
		end
		
		return true
	else if coder and coder=="uploads" then
		local hub_uploads = Core.GetPtokaXPath().."scripts/".."created_uploads.txt"
		local f = assert(io.open(hub_uploads, "r"))
		local t2 = f:read("*all")
		Core.SendToUser(user ,"|"..t2.."|" )
		f:close()		
		return true
	else if command == "clean" and arg ~= nil then
		days = tonumber(arg)
		Clean_uploads(days)
		Core.SendToUser(user,"Uploads table cleaned")
		return true
	end	
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

Write_to_uploads = function() -- instead of generating uploads dynamically every time , this stores the modified uploads in a text file
	reply = ""
	for dates, genres_list in pairs(uploads) do
		local e,s,date,month  = string.find(dates,"(%d+) (%a+)")
		date = text_date(date)
		dates = date.." "..month
		reply = reply.."\n \t\t ----------<<<<"..dates..">>>>----------\n"
		for genres,upload_by_genre in pairs(genres_list) do
			genre =string.upper(genres)
			if upload_by_genre[1] then 
			reply = reply.."\n"..string.rep("+",45).."\n\t\t"..genre.."\n"..string.rep("+",45).."\n"
			end
			for id = 1,#upload_by_genre do
				reply = reply..id.."\t"..upload_by_genre[id]["Magnet"].." - by "..upload_by_genre[id]["Uploader"].."\r\n"
			end
		end
	end	
local handle = io.open(Core.GetPtokaXPath().."scripts/".."created_uploads.txt","w")
handle:write(reply)
handle:close(handle)
end

OnTimer = function(timer)
	
	Clean_uploads()
	
end

Clean_uploads = function(days)
	dates = {}
	for i = 0,days-1 do
		date = os.date("%d %b",os.time()-(i)*24*60*60)
		dates[date] = true
	end
	for i,v in pairs(uploads) do
		chek_date = v["Date"] 
		if not dates[chek_date]  then			
			table.remove(uploads,i)
			Save_File(uploads_path,uploads,"uploads")	
		end			
	end
	Write_to_uploads()
end

text_date = function(date)

if date%20 == 1 then
	date = tostring(date)
	return date.."st"
elseif date%20== 2 then
	date = tostring(date)
	return date.."nd"	
elseif date%20== 3 then
	date = tostring(date)
	return date.."rd"
else
	return date.."th"	
end

end