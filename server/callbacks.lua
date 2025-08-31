

local QBCore = nil
local QBX = nil
local ESX = nil

local function InitializeFramework()
    if Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'qbx' then
        QBX = exports['qbx-core']:GetSharedObject()
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end

local function GetPlayer(source)
    if Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbx' then
        return QBX.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
    return nil
end

local function RegisterCallback(name, cb)
    if Config.Framework == 'qbcore' then
        QBCore.Functions.CreateCallback(name, cb)
    elseif Config.Framework == 'qbx' then
        QBX.Functions.CreateCallback(name, cb)
    elseif Config.Framework == 'esx' then
        ESX.RegisterServerCallback(name, cb)
    end
end

local function CountPolice()
    local policeCount = 0

    if Config.Framework == 'qbcore' then
        local players = QBCore.Functions.GetQBPlayers()
        for _, player in pairs(players) do
            if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                policeCount = policeCount + 1
            end
        end
    elseif Config.Framework == 'qbx' then
        local players = QBX.Functions.GetQBPlayers()
        for _, player in pairs(players) do
            if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                policeCount = policeCount + 1
            end
        end
    elseif Config.Framework == 'esx' then
        local xPlayers = ESX.GetExtendedPlayers('job', 'police')
        policeCount = #xPlayers
    end

    return policeCount
end

local function HasItem(source, item)
    local player = GetPlayer(source)

    if not player then return false end

    if Config.Framework == 'qbcore' then
        return player.Functions.GetItemByName(item) ~= nil
    elseif Config.Framework == 'qbx' then
        return player.Functions.GetItemByName(item) ~= nil
    elseif Config.Framework == 'esx' then
        local xItem = player.getInventoryItem(item)
        return xItem ~= nil and xItem.count > 0
    end

    return false
end

local function InitializeCallbacks()

    RegisterCallback('gs-vendrob:server:checkPoliceCount', function(source, cb)
        local policeCount = CountPolice()
        cb(policeCount)
    end)

    RegisterCallback('gs-vendrob:server:checkRequiredItem', function(source, cb)
        local hasItem = HasItem(source, Config.RequiredItem.Name)
        cb(hasItem)
    end)

    RegisterCallback('gs-vendrob:server:checkCooldown', function(source, cb, machineId)

        cb(false)
    end)

    RegisterCallback('gs-vendrob:server:getRandomEvent', function(source, cb)
        if not Config.RandomEvents.Enabled then
            cb(nil)
            return
        end

        if math.random(1, 100) > Config.RandomEvents.Chance then
            cb(nil)
            return
        end

        local totalChance = 0
        for _, event in pairs(Config.RandomEvents.Events) do
            totalChance = totalChance + event.chance
        end

        local randomNum = math.random(1, totalChance)
        local currentChance = 0

        for _, event in pairs(Config.RandomEvents.Events) do
            currentChance = currentChance + event.chance
            if randomNum <= currentChance then
                cb(event)
                return
            end
        end

        cb(nil)
    end)

    RegisterCallback('gs-vendrob:server:getRewards', function(source, cb)
        local rewards = {
            money = math.random(Config.Rewards.Money.Min, Config.Rewards.Money.Max),
            items = {}
        }

        if Config.Rewards.Items.Enabled and math.random(1, 100) <= Config.Rewards.Items.Chance then

            local possibleItems = {}
            local totalChance = 0

            for _, item in pairs(Config.Rewards.Items.PossibleItems) do
                totalChance = totalChance + item.chance
                table.insert(possibleItems, {
                    name = item.name,
                    min = item.min,
                    max = item.max,
                    chance = totalChance
                })
            end

            local randomNum = math.random(1, totalChance)
            local selectedItem = nil

            for _, item in pairs(possibleItems) do
                if randomNum <= item.chance then
                    selectedItem = item
                    break
                end
            end

            if selectedItem then
                local itemAmount = math.random(selectedItem.min, selectedItem.max)
                table.insert(rewards.items, {
                    name = selectedItem.name,
                    amount = itemAmount
                })
            end
        end

        cb(rewards)
    end)
end

Citizen.CreateThread(function()

    InitializeFramework()

    InitializeCallbacks()

    if Config.Debug then
        print('GS-VendRob: Server callbacks initialized')
    end
end)