

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

local function CreatePoliceBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Dispatch.BlipSprite)
    SetBlipColour(blip, Config.Dispatch.BlipColor)
    SetBlipScale(blip, Config.Dispatch.BlipScale)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vending Machine Robbery")
    EndTextCommandSetBlipName(blip)

    Citizen.SetTimeout(Config.Dispatch.BlipDuration * 1000, function()
        RemoveBlip(blip)
    end)
end

RegisterNetEvent('gs-vendrob:client:policeAlert', function(data)
    local playerPed = PlayerPedId()
    local playerData = nil

    if Config.Framework == 'qbcore' then
        playerData = QBCore.Functions.GetPlayerData()
    elseif Config.Framework == 'qbx' then
        playerData = QBX.Functions.GetPlayerData()
    elseif Config.Framework == 'esx' then
        playerData = ESX.GetPlayerData()
    end

    local isPolice = false
    if Config.Framework == 'qbcore' or Config.Framework == 'qbx' then
        isPolice = playerData.job.name == 'police' and playerData.job.onduty
    elseif Config.Framework == 'esx' then
        isPolice = playerData.job.name == 'police'
    end

    if isPolice then

        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('Vending Machine Robbery at ' .. data.streetLabel, 'police')
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('Vending Machine Robbery at ' .. data.streetLabel, 'police')
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('Vending Machine Robbery at ' .. data.streetLabel)
        end

        CreatePoliceBlip(data.coords)

        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'dispatch', 0.3)
    end
end)

Citizen.CreateThread(function()

    Wait(1000)

    InitializeFramework()

    if Config.Debug then
        print('GS-VendRob: Police alert system initialized')
    end
end)