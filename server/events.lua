

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

local function AddMoney(player, amount, type)
    if Config.Framework == 'qbcore' then
        player.Functions.AddMoney(type, amount)
    elseif Config.Framework == 'qbx' then
        player.Functions.AddMoney(type, amount)
    elseif Config.Framework == 'esx' then
        if type == 'cash' then
            player.addMoney(amount)
        else
            player.addAccountMoney('bank', amount)
        end
    end
end

local function AddItem(player, item, amount)
    if Config.Framework == 'qbcore' then
        player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], "add")
    elseif Config.Framework == 'qbx' then
        player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBX.Shared.Items[item], "add")
    elseif Config.Framework == 'esx' then
        player.addInventoryItem(item, amount)
    end
end

RegisterNetEvent('gs-vendrob:server:forceDispatchAlert', function(coords)
    local source = source

    TriggerClientEvent('gs-vendrob:client:getStreetName', source, coords, function(streetName)

        local data = {
            coords = coords,
            streetLabel = streetName
        }

        local players = nil

        if Config.Framework == 'qbcore' then
            players = QBCore.Functions.GetQBPlayers()
            for _, player in pairs(players) do
                if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                    TriggerClientEvent('gs-vendrob:client:policeAlert', player.PlayerData.source, data)
                end
            end
        elseif Config.Framework == 'qbx' then
            players = QBX.Functions.GetQBPlayers()
            for _, player in pairs(players) do
                if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
                    TriggerClientEvent('gs-vendrob:client:policeAlert', player.PlayerData.source, data)
                end
            end
        elseif Config.Framework == 'esx' then
            local xPlayers = ESX.GetExtendedPlayers('job', 'police')
            for _, xPlayer in pairs(xPlayers) do
                TriggerClientEvent('gs-vendrob:client:policeAlert', xPlayer.source, data)
            end
        end
    end)
end)

RegisterNetEvent('gs-vendrob:server:giveBonusReward', function()
    local source = source
    local player = GetPlayer(source)

    if not player then return end

    local bonusMultiplier = math.random(20, 30) / 10 
    local moneyAmount = math.floor(math.random(Config.Rewards.Money.Min, Config.Rewards.Money.Max) * bonusMultiplier)

    AddMoney(player, moneyAmount, Config.Rewards.Money.Type)

    if Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', source, 'You found $' .. moneyAmount .. ' in the hidden compartment!', 'success')
    elseif Config.Framework == 'qbx' then
        TriggerClientEvent('QBX:Notify', source, 'You found $' .. moneyAmount .. ' in the hidden compartment!', 'success')
    elseif Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, 'You found $' .. moneyAmount .. ' in the hidden compartment!')
    end

    if math.random(1, 100) <= 30 then 
        local rareItems = {
            {name = 'goldbar', min = 1, max = 1, chance = 10},
            {name = 'rolex', min = 1, max = 2, chance = 30},
            {name = 'diamond', min = 1, max = 1, chance = 5},
            {name = 'cryptostick', min = 1, max = 1, chance = 15},
            {name = 'electronickit', min = 1, max = 1, chance = 40},
        }

        local possibleItems = {}
        local totalChance = 0

        for _, item in pairs(rareItems) do
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
            AddItem(player, selectedItem.name, itemAmount)

            if Config.Framework == 'qbcore' then
                TriggerClientEvent('QBCore:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name .. '!', 'success')
            elseif Config.Framework == 'qbx' then
                TriggerClientEvent('QBX:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name .. '!', 'success')
            elseif Config.Framework == 'esx' then
                TriggerClientEvent('esx:showNotification', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name .. '!')
            end
        end
    end
end)

RegisterNetEvent('gs-vendrob:client:getStreetName', function(coords, cb)
    local source = source
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)

    if crossingHash ~= 0 then
        local crossingName = GetStreetNameFromHashKey(crossingHash)
        streetName = streetName .. ' & ' .. crossingName
    end

    cb(streetName)
end)

Citizen.CreateThread(function()

    InitializeFramework()

    if Config.Debug then
        print('GS-VendRob: Server events system initialized')
    end
end)