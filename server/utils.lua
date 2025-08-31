

function DebugPrint(message)
    if Config.Debug then
        print('[GS-VendRob] ' .. message)
    end
end

function LogToConsole(message, level)
    level = level or 'info'

    local prefix = '^3[GS-VendRob]^7 '

    if level == 'error' then
        prefix = '^1[GS-VendRob ERROR]^7 '
    elseif level == 'warning' then
        prefix = '^3[GS-VendRob WARNING]^7 '
    elseif level == 'success' then
        prefix = '^2[GS-VendRob]^7 '
    elseif level == 'debug' and Config.Debug then
        prefix = '^5[GS-VendRob DEBUG]^7 '
    elseif level == 'debug' and not Config.Debug then
        return 
    end

    print(prefix .. message)
end

function GetRandomItem(table)
    if #table == 0 then return nil end
    return table[math.random(1, #table)]
end

function GetRandomWeightedItem(items)
    local totalWeight = 0

    for _, item in pairs(items) do
        totalWeight = totalWeight + (item.chance or 1)
    end

    local randomNum = math.random(1, totalWeight)
    local currentWeight = 0

    for _, item in pairs(items) do
        currentWeight = currentWeight + (item.chance or 1)
        if randomNum <= currentWeight then
            return item
        end
    end

    return items[1]
end

function GetRandomAmount(min, max)
    return math.random(min, max)
end

function TableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function TableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60

    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function GetPlayerIdentifier(source, type)
    type = type or 'license'

    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, type .. ':') then
            return identifier
        end
    end

    return nil
end

function GetPlayerLicense(source)
    return GetPlayerIdentifier(source, 'license')
end

function GetPlayerDiscord(source)
    local discordId = GetPlayerIdentifier(source, 'discord')
    if discordId then
        return string.gsub(discordId, 'discord:', '')
    end
    return nil
end

function GetPlayerSteam(source)
    local steamId = GetPlayerIdentifier(source, 'steam')
    if steamId then
        return string.gsub(steamId, 'steam:', '')
    end
    return nil
end

function GetPlayerIP(source)
    local ip = GetPlayerIdentifier(source, 'ip')
    if ip then
        return string.gsub(ip, 'ip:', '')
    end
    return nil
end

function IsValidSource(source)
    if source == nil then return false end
    return GetPlayerPing(source) > 0
end

function GetAllPlayers()
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        table.insert(players, tonumber(playerId))
    end

    return players
end

function GetPlayersByJob(job)
    local players = {}

    if Config.Framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local qbPlayers = QBCore.Functions.GetQBPlayers()

        for _, player in pairs(qbPlayers) do
            if player.PlayerData.job.name == job then
                table.insert(players, player.PlayerData.source)
            end
        end
    elseif Config.Framework == 'qbx' then
        local QBX = exports['qbx-core']:GetCoreObject()
        local qbxPlayers = QBX.Functions.GetQBPlayers()

        for _, player in pairs(qbxPlayers) do
            if player.PlayerData.job.name == job then
                table.insert(players, player.PlayerData.source)
            end
        end
    elseif Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayers = ESX.GetExtendedPlayers('job', job)

        for _, xPlayer in pairs(xPlayers) do
            table.insert(players, xPlayer.source)
        end
    end

    return players
end

function GetPoliceCount()
    local count = 0

    if Config.Framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local players = QBCore.Functions.GetQBPlayers()

        for _, player in pairs(players) do
            if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                count = count + 1
            end
        end
    elseif Config.Framework == 'qbx' then
        local QBX = exports['qbx-core']:GetCoreObject()
        local players = QBX.Functions.GetQBPlayers()

        for _, player in pairs(players) do
            if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                count = count + 1
            end
        end
    elseif Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayers = ESX.GetExtendedPlayers('job', 'police')
        count = #xPlayers
    end

    return count
end

function RegisterCallback(name, cb)
    if Config.Framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateCallback(name, cb)
    elseif Config.Framework == 'qbx' then
        local QBX = exports['qbx-core']:GetCoreObject()
        QBX.Functions.CreateCallback(name, cb)
    elseif Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterServerCallback(name, cb)
    end
end

function TriggerCallbackSync(source, name, cb, ...)
    if Config.Framework == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.TriggerCallback(name, source, cb, ...)
    elseif Config.Framework == 'qbx' then
        local QBX = exports['qbx-core']:GetCoreObject()
        QBX.Functions.TriggerCallback(name, source, cb, ...)
    elseif Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.TriggerServerCallback(name, source, cb, ...)
    end
end