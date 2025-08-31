

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

local function RemoveItem(player, item, amount)
    if Config.Framework == 'qbcore' then
        player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], "remove")
    elseif Config.Framework == 'qbx' then
        player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBX.Shared.Items[item], "remove")
    elseif Config.Framework == 'esx' then
        player.removeInventoryItem(item, amount)
    end
end

local function GenerateRewards(source)
    local player = GetPlayer(source)
    if not player then return end

    if not Config.Rewards.Enabled then return end

    if Config.Rewards.UseMadLoot then

        if GetResourceState('mad-loot') == 'started' then
            exports['mad-loot']:GiveLoot(source, Config.Rewards.MadLootTableName, Config.Rewards.MadLootTableTiers, Config.Rewards.MadLootTableUseGuaranteed)
            return
        end
    end

    if Config.Rewards.Money.Enabled and math.random(1, 100) <= Config.Rewards.Money.Chance then
        local moneyAmount = math.random(Config.Rewards.Money.Min, Config.Rewards.Money.Max)
        AddMoney(player, moneyAmount, Config.Rewards.Money.Type)

        if Config.Framework == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', source, 'You found $' .. moneyAmount, 'success', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            TriggerClientEvent('QBX:Notify', source, 'You found $' .. moneyAmount, 'success', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', source, 'You found $' .. moneyAmount)
        end
    end

    if Config.Rewards.CommonItems.Enabled and math.random(1, 100) <= Config.Rewards.CommonItems.Chance then

        local possibleItems = {}
        local totalChance = 0

        for _, item in pairs(Config.Rewards.CommonItems.Items) do
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
                TriggerClientEvent('QBCore:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name, 'success', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'qbx' then
                TriggerClientEvent('QBX:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name, 'success', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'esx' then
                TriggerClientEvent('esx:showNotification', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name)
            end
        end
    end

    if Config.Rewards.RareItems.Enabled and math.random(1, 100) <= Config.Rewards.RareItems.Chance then

        local possibleItems = {}
        local totalChance = 0

        for _, item in pairs(Config.Rewards.RareItems.Items) do
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
                TriggerClientEvent('QBCore:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name, 'success', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'qbx' then
                TriggerClientEvent('QBX:Notify', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name, 'success', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'esx' then
                TriggerClientEvent('esx:showNotification', source, 'You found ' .. itemAmount .. 'x ' .. selectedItem.name)
            end
        end
    end
end

local function HandleRandomEvent(source, eventName)
    if eventName == 'taze' then
        TriggerClientEvent('gs-vendrob:client:getTazed', source)
    elseif eventName == 'alarm' then
        TriggerClientEvent('gs-vendrob:client:triggerAlarm', source)
    elseif eventName == 'break_tool' then
        TriggerClientEvent('gs-vendrob:client:breakTool', source)
    elseif eventName == 'security_camera' then
        TriggerClientEvent('gs-vendrob:client:securityCamera', source)
    elseif eventName == 'bonus_reward' then
        TriggerClientEvent('gs-vendrob:client:bonusReward', source)

    elseif eventName == 'blow_up' then
        TriggerClientEvent('gs-vendrob:client:blowUp', source)

    end

end

local function AlertPolice(data)

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
end

RegisterNetEvent('gs-vendrob:server:updatePoliceCount', function()
    local policeCount = CountPolice()
    TriggerClientEvent('gs-vendrob:client:updatePoliceCount', -1, policeCount)
end)

RegisterNetEvent('gs-vendrob:server:rewardPlayer', function(coords)
    local source = source

    GenerateRewards(source)

    if Config.Debug then
        print('GS-VendRob: Player ' .. GetPlayerName(source) .. ' robbed a vending machine at ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z)
    end
end)

RegisterNetEvent('gs-vendrob:server:removeItem', function(item)
    local source = source
    local player = GetPlayer(source)

    if player then
        RemoveItem(player, item, 1)
    end
end)

RegisterNetEvent('gs-vendrob:server:triggerRandomEvent', function(eventName)
    local source = source
    HandleRandomEvent(source, eventName)
end)

RegisterNetEvent('gs-vendrob:server:alertPolice', function(data)
    AlertPolice(data)
end)

Citizen.CreateThread(function()

    InitializeFramework()

    if Config.Debug then
        print('GS-VendRob: Server initialized')
    end
end)