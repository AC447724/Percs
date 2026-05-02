local P, H = game.PlaceId, "https://www.esoteric.win/api/v1/rbf/"
local M = {
    [286090429] = "arsenal",
    [2753915549] = "bloxfruits", [4442272183] = "bloxfruits", [7449423635] = "bloxfruits", 
    [11424731604] = "bloxfruits", [15335232591] = "bloxfruits", [10594246664] = "bloxfruits", 
    [994732206] = "bloxfruits", [6403373529] = "slap-battles", [142823291] = "murder-mystery-2", 
    [3956818381] = "ninja-legends", [3101667897] = "legends-of-speed", [9872472334] = "evade", 
    [6961824067] = "ftap", [7326934954] = "99-nights-in-the-forest"
}

local MessageBox = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/NotificationGUI/main/source.lua"))()

local function Notify(msg, icon, buttons)
    MessageBox.Show({
        Text = "esoteric.win",
        Description = msg,
        MessageBoxIcon = icon or "Warning",
        MessageBoxButtons = buttons or "OK"
    })
end

local function Execute()
    if M[P] then
        local success, result = pcall(function() return game:HttpGet(H .. M[P]) end)
        if success and result and #result > 0 then
            local func = loadstring(result)
            if func then
                local s, e = pcall(func)
                if not s then Notify("Execution Error: " .. tostring(e), "Error") end
            else
                Notify("Compiler Error: Failed to parse script.", "Error")
            end
        else
            Notify("API Error: Could not reach the server.", "Error")
        end
    else
        Notify("Place ID " .. P .. " is not supported.\nJoin discord.gg/esoteric for updates.", "Warning")
    end
end

if M[P] then
    MessageBox.Show({
        Position = UDim2.new(0.5,0,0.5,0),
        Text = "esoteric.win",
        Description = "Supported game found: " .. M[P]:upper() .. "\n\nWould you like to load the script?",
        MessageBoxIcon = "Question",
        MessageBoxButtons = "YesNo",
        Result = function(res)
            if res == "Yes" then
                Execute()
            end
        end
    })
else
    Notify("This game is not currently supported.\nDiscord: esoteric.win/discord", "Warning")
end
