--Based on anagram by Vestor
user_list = {}
words_table = "word"
scores_table = "score"
Core = require("Core")
DB_PATH = Core.GetPtokaXPath() .. "scripts/" .. "anagram.sqlite3"
sqlite3 = require("lsqlite3")
db_raw = sqlite3.open(DB_PATH)

isGameRunning = false
Game = {
    isRunning = false,
    points = 25,
    word = "",
    hints = {},
    hint_counter = 0,
    fails = 0,
    hint_timer_id = nil,
    game_timer_id = nil,
    anagram = ""
}

OnStartup = function()

end

PickRandomWord = function()
    local stmt = string.format("SELECT * FROM word ORDER BY RANDOM() LIMIT 1", words_table)
    for word_row in db_raw:nrows(stmt) do
        return word_row.word
    end
end

GetScoreForNick = function(nick)
    for score in db_raw:nrows(string.format("SELECT * from %s where nick ='%s'", scores_table, nick)) do
        return score.score
    end
    return 0
end
AddPointsToUser = function(nick, points)
    local currentScore = GetScoreForNick(nick)
    currentScore = currentScore + points
    db_raw:exec(string.format("REPLACE into score VALUES('%s', %s)", nick, currentScore))
end

function ChatArrival(user, data)
    local _, _, cmd = data:find("^%b<> (%p%a+)")
    local _, _, arg = data:find("^%b<> %p%a+ (%S+)|")

    local s, e, var1 = data:find("%b<>%s+(%a+)")
    if cmd and cmd == "+an" and arg == "start" then
        if not Game.isRunning then
            Core.SendToAll("<[The Riddler]> " .. user.sNick .. " started Riddler's Anagram Challenge\n")
            startGame()
            return true
        else
            Core.SendToUser(user, "<[The Riddler]> A challenge is already underway " .. user.sNick .. "\n")
            return true
        end
    end
    if cmd and cmd == "+an" and arg == "showscores" then
        local scores = "                              Nick                      Score\n"
        scores = scores .. "=============================================================\n"
        scores = scores .. pair_by_score()
        Core.SendToUser(user, "\n                             RIDDLER's MOST WANTED \n                                  In Nebula\n\n" .. scores .. "\n")
    end
    if cmd and cmd == "+an" and arg == "myscore" then
        local curr_time = os.date("%I") ..
                ":" .. os.date("%M") .. " " .. os.date("%p") .. "   " .. os.date("%A") .. " " .. os.date("%x")
        local scores = "\n          Your Score as of " .. curr_time .. " is \n"
        scores = scores .. "             " .. user.sNick .. "  ;  Score : " .. GetScoreForNick(user.sNick) .. "\n"
        Core.SendToUser(user, scores)
    end
    if cmd and cmd == "+an" and arg == "stop" then
        if Game.isRunning then
            Core.SendToAll(
                    "<[The Riddler]>  " .. user.sNick .. " forced you all to give up on Riddler's Anagram Challenge"
            )
            stopGame()
        else
            Core.SendToUser(user, "<[The Riddler]>  Hey " .. user.sNick .. " there is no running challenge !! wanna start one type +an start")
        end
        Game.isRunning = false
        return true
    end

    if var1 then
        if var1:upper() == Game.word then
            AddPointsToUser(user.sNick, Game.points)
            Core.SendToAll(
                    "<[The Riddler]> The Riddler rewards " ..
                            user.sNick .. " with [" .. Game.points .. "] points on guessing the right word [" .. Game.word .. "]\n"
            )
            stopGame()
            Game.game_timer_id = TmrMan.AddTimer(7000, startGame)
            return true
        end
    end
end

function hints_display(Id)

    if Game.isRunning then
        if Game.hint_counter < 5 then
            local counter = Game.hint_counter
            Core.SendToAll(
                    "<[The Riddler]>    Hint(" .. counter .. "/4):                    [ " .. formatWord(Game.hints[counter]) .. " ]     ###   < " .. formatWord(Game.anagram) .. " >"
            )
            Game.points = Game.points - 5
            Game.hint_counter = Game.hint_counter + 1
        else
            Core.SendToAll("<[The Riddler]> You should take Batman's help to solve anagrams! The word was  [" .. Game.word .. "]")
            local fails = Game.fails + 1
            stopGame()
            Game.fails = fails
            Game.game_timer_id = TmrMan.AddTimer(7000, startGame)
        end
    end
end

function pair_by_score()
    local score_list = ""
    local i = 1
    for score in db_raw:nrows(string.format("SELECT * FROM %s", scores_table)) do
        local x = string.len(score.nick)
        x = 20 - x
        local sp = ""
        for j = 1, x / 2 do
            sp = sp .. " -"
        end
        score_list = score_list .. "                              " .. i .. ") " .. score.nick .. sp .. score.score .. " \n"
        i = i + 1
    end
    return score_list
end

function generateAnagram(word)
    local bytes = { word:byte(1, -1) }
    table.sort(bytes)
    for i = 1, #bytes, 1 do
        local rand = math.random(#bytes)
        bytes[i], bytes[rand] = bytes[rand], bytes[i]
    end
    return string.char(unpack(bytes))
end

function getHints(word)
    local hints = {}
    local hints_length = 0
    while hints_length < 4 do
        local index1 = math.random(word:len())
        local index2 = math.random(word:len())
        if (index1 ~= index2) then
            local hintBytes = { string.rep("?", word:len()):byte(1, -1) }
            hintBytes[index1] = word:byte(index1)
            hintBytes[index2] = word:byte(index2)
            local hint = string.char(unpack(hintBytes))
            if (not hints[hint]) then
                hints[hint] = true
                hints_length = hints_length + 1
            end
        end
    end
    local hintArray = {}
    for i, v in pairs(hints) do
        table.insert(hintArray, i)
    end
    return hintArray
end

function removeTimers()
    if Game.game_timer_id then
        TmrMan.RemoveTimer(Game.game_timer_id)
    end
    if Game.hint_timer_id then
        TmrMan.RemoveTimer(Game.hint_timer_id)
    end
end

function stopGame()
    removeTimers()
    Game = {
        isRunning = false,
        points = 25,
        word = "",
        hints = {},
        hint_counter = 0,
        fails = 0,
        hint_timer_id = nil,
        game_timer_id = nil,
        anagram = ""
    }
end

function startGame()
    if Game.fails > 4 then
        stopGame()
        Core.SendToAll("<[The Riddler]> The Riddler hysterically laughs at your ignorance and stops the anagram !")
        return
    end
    removeTimers()
    Game.isRunning = true
    Game.word = (PickRandomWord()):upper()
    Game.anagram = generateAnagram(Game.word)

    Game.hint_counter = 1
    Core.SendToAll("<[The Riddler]> Riddler's new riddle is    < " .. formatWord(Game.anagram) .. " >")
    Game.points = 25
    Game.hints = getHints(Game.word)
    Game.hint_timer_id = TmrMan.AddTimer(7000, hints_display)
end

function formatWord(word)
    local formattedWord = ""
    for co = 1, string.len(word) do
        formattedWord = formattedWord .. string.sub(word, co, co) .. " "
    end
    return formattedWord
end