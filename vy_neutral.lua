function ChatArrival(user, sData)
	bot = "[DeZire-BOT]"
	local cmd = string.gsub(sData, "%b<> ", ""):sub(1, 5)	
	if cmd == "!mode" or cmd == "+mode" then
		Core.GetUserAllData(user)
		if user.sMode == "A" then
			result = "You are in Active Mode"
		else 
			result = "You are in Passive Mode. Try changing to active mode."
		end		
		Core.SendToUser(user,"<"..bot.."> "..result)	
		return true
	end
end