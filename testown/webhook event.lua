local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local WebhookURL = "https://discord.com/api/webhooks/1497200046171750512/_AzTmRnD8eOiPNy6XxdFv9hus2jaRk1m2kip6PsrroPlj7SpxIuY0OKXbDVU3JoCZxx2"

-- 🔒 SAFE GET FUNCTION
local function safe(path, default)
    local ok, result = pcall(function()
        return path()
    end)
    return ok and result or default
end

-- 📦 GET DATA (ANTI ERROR)
local zones = safe(function() return workspace:WaitForChild("zones") end)
local fishing = zones and safe(function() return zones:WaitForChild("fishing") end)

local adminEvent = safe(function()
    return ReplicatedStorage:WaitForChild("world"):WaitForChild("admin_event")
end)

local cosmicRelic = safe(function()
    return ReplicatedStorage.shared.modules.SharedAdminEvent.Events.Unique.CosmicRelic
end)

local cosmicLuck = safe(function()
    return ReplicatedStorage.shared.modules.SharedAdminEvent.Events.Unique.CosmicRelicLuck
end)

local uptimeVal = safe(function()
    return ReplicatedStorage.world.uptime
end)

local weatherVal = safe(function()
    return ReplicatedStorage.world.clientWeather
end)

-- 🎣 EVENTS
local activeEvents = {}
if fishing then
    for _, v in pairs(fishing:GetChildren()) do
        table.insert(activeEvents, v.Name)
    end
end

local activeEventsText = (#activeEvents > 0 and table.concat(activeEvents, ", ")) or "None"

-- 🛠 ADMIN EVENT
local adminEventText = (adminEvent and adminEvent.Value ~= "" and adminEvent.Value) or "None"

-- 🌌 COSMIC
local cosmicText = tostring((cosmicRelic and cosmicRelic.Value) or 0)
local cosmicLuckText = tostring((cosmicLuck and cosmicLuck.Value) or 0)

-- ⏱ TIME FORMAT
local function formatTime(seconds)
    seconds = tonumber(seconds) or 0
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    return string.format("%dD %02dH %02dM", d, h, m)
end

local uptime = formatTime(uptimeVal and uptimeVal.Value)

-- 🌦 WEATHER
local weather = (weatherVal and weatherVal.Value) or "Unknown"

-- 🎮 SERVER INFO
local placeId = game.PlaceId
local jobId = game.JobId
local joinLink = "https://www.roblox.com/games/"..placeId.."?gameInstanceId="..jobId

-- 🖼 THUMB FIX (LINK LU ERROR → ganti fallback)
local thumbnail = "https://cdn.discordapp.com/attachments/1494647762904547458/1494656281091244122/logo.png?ex=69eca122&is=69eb4fa2&hm=4423535262762c78540ffee79223868befee8c4dc92e85146f87b7a367f165f9&"

-- 📡 WEBHOOK DATA
local data = {
    username = "Fisch Server Monitor",
    avatar_url = thumbnail,
    embeds = {{
        title = "🌊 Fisch Server Status",
        color = 3447003,

        thumbnail = { url = thumbnail },

        fields = {
            {
                name = "🆔 Server",
                value = "`"..string.sub(jobId,1,8).."`\n"..jobId,
                inline = false
            },
            {
                name = "🎣 Active Events",
                value = activeEventsText,
                inline = false
            },
            {
                name = "🛠 Admin Event",
                value = adminEventText,
                inline = false
            },
            {
                name = "🌌 Cosmic Relic",
                value = "Relic: "..cosmicText.."\nLuck: "..cosmicLuckText,
                inline = true
            },
            {
                name = "⏱ Uptime",
                value = uptime,
                inline = true
            },
            {
                name = "🌦 Weather",
                value = weather,
                inline = true
            },
            {
                name = "📍 Server Info",
                value = "PlaceId: "..placeId.."\n[🔗 Join Server]("..joinLink..")",
                inline = false
            }
        },

        footer = {
            text = "Lexs Hub Logger"
        }
    }}
}

-- 🚀 REQUEST FIX + DEBUG + RETRY
local request = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

if not request then
    warn("❌ Executor tidak support HTTP")
    return
end

for i = 1, 5 do
    local success, response = pcall(function()
        return request({
            Url = WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)

    if success and response and (response.StatusCode == 200 or response.StatusCode == 204) then
        print("✅ Webhook sent!")
        break
    else
        warn("❌ Gagal kirim webhook ke-"..i)
        task.wait(1)
    end
end
