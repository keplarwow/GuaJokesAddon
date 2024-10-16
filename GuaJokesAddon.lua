
-- GuaJokesAddon.lua

-- Variables for tracking "Gua" mentions
local guaCount = 0
local guaThreshold = math.random(50, 100) -- Pick a random number between 50 and 100

-- Function to select a random joke
local function GetRandomJoke(name)
    if jokes then -- Ensure jokes is loaded before using it
        local jokeIndex = math.random(1, #jokes)
        return string.format(jokes[jokeIndex], name)
    else
        return "Jokes not available."
    end
end

local function GetRandomRaidJoke()
    local raidSize = GetNumGroupMembers()

    if raidSize > 0 then
        local randomIndex = math.random(1, raidSize)
        -- Get all return values from GetRaidRosterInfo
        local randomRaidMemberName = GetRaidRosterInfo(randomIndex)

        if randomRaidMemberName then
            -- Split the name if there's a hyphen
            local nameOnly = randomRaidMemberName
            local dashPosition = string.find(randomRaidMemberName, "-")
            if dashPosition then
                nameOnly = string.sub(randomRaidMemberName, 1, dashPosition - 1)
            end
            return GetRandomJoke(nameOnly)
        else
            return "Couldn't find a raid member."
        end
    else
        return "No raid members found."
    end
end

-- Function to check for "Gua" in chat and tell a random joke after a threshold is met
local function CheckForGuaInChat(event, msg, author)
    if string.find(string.lower(msg), "gua") then
        guaCount = guaCount + 1
        -- print("Gua mentioned " .. guaCount .. " times. Threshold: " .. guaThreshold)

        if guaCount >= guaThreshold then
            local joke = GetRandomJoke("Gua")
            SendChatMessage(joke, "SAY")

            -- Reset the count and pick a new random threshold
            guaCount = 0
            guaThreshold = math.random(25, 75)
            -- print("New Gua threshold: " .. guaThreshold)
        end
    end
end

-- Register event for chat messages
local chatFrame = CreateFrame("Frame")
chatFrame:RegisterEvent("CHAT_MSG_SAY")
chatFrame:RegisterEvent("CHAT_MSG_PARTY")
chatFrame:RegisterEvent("CHAT_MSG_GUILD")
chatFrame:RegisterEvent("CHAT_MSG_RAID")
chatFrame:RegisterEvent("CHAT_MSG_WHISPER")

chatFrame:SetScript("OnEvent", function(self, event, msg, author)
    CheckForGuaInChat(event, msg, author)
end)

-- Function to display the command hint
local function ShowCommandHint()
  print("|cffffff00GuaJokesAddon loaded! Type |cff00ff00/guajokeaddon|cffffff00 to show or hide the joke buttons.|r")
end

-- Event for player login to ensure all files are loaded before accessing the jokes
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    jokes = _G.jokes -- Assign the jokes table after the PLAYER_LOGIN event
    ShowCommandHint()
end)

-- Create the Gua joke button
local guaButton = CreateFrame("Button", "GuaJokeButton", UIParent, "UIPanelButtonTemplate")
guaButton:SetSize(120, 40) -- width, height
guaButton:SetText("Tell Gua Joke")
guaButton:SetPoint("TOP", UIParent, "TOP", -100, 0) -- Adjust the position as needed

-- Gua joke button click event
guaButton:SetScript("OnClick", function()
    local joke = GetRandomJoke("Gua")
    SendChatMessage(joke, "SAY")
end)

-- Create the Raid joke button
local raidButton = CreateFrame("Button", "RaidJokeButton", UIParent, "UIPanelButtonTemplate")
raidButton:SetSize(150, 40) -- width, height
raidButton:SetText("Tell Raid Joke")
raidButton:SetPoint("TOP", UIParent, "TOP", 100, 0) -- Adjust the position as needed

-- Raid joke button click event
raidButton:SetScript("OnClick", function()
    local joke = GetRandomRaidJoke()
    SendChatMessage(joke, "SAY")
end)

-- Slash command to show or hide both buttons
SLASH_GUAJOKE1 = "/guajoke"
SlashCmdList["GUAJOKE"] = function(msg)
    if guaButton:IsShown() then
        guaButton:Hide()
        raidButton:Hide()
    else
        guaButton:Show()
        raidButton:Show()
    end
end
