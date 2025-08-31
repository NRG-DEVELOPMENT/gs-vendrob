

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

local function ShowNotification(message, type)
    type = type or 'primary'

    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Framework == 'qbx' then
        QBX.Functions.Notify(message, type)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    end
end

RegisterNetEvent('gs-vendrob:client:getTazed', function()
    local playerPed = PlayerPedId()

    ShowNotification('You got shocked by the vending machine!', 'error')

    LoadAnimDict("missminuteman_1ig_2")
    TaskPlayAnim(playerPed, "missminuteman_1ig_2", "handsup_enter", 8.0, -8.0, 2000, 0, 0, false, false, false)

    Wait(1000)

    SetPedToRagdoll(playerPed, 5000, 5000, 0, 0, 0, 0)

    local coords = GetEntityCoords(playerPed)
    local prop = CreateObject(`prop_cs_mini_tv`, coords.x, coords.y, coords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 18905), 0.1, 0.1, 0.1, 0, 0, 0, true, true, false, true, 1, true)

    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)

    local dict = "core"
    local particleName = "ent_sht_electrical_box"

    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)
    local particleHandle = StartParticleFxLoopedOnEntity(particleName, prop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    AnimpostfxPlay("Rampage", 0, true)

    Wait(5000)

    AnimpostfxStop("Rampage")
    StopParticleFxLooped(particleHandle, 0)
    DeleteEntity(prop)
end)

RegisterNetEvent('gs-vendrob:client:triggerAlarm', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    ShowNotification('The vending machine alarm went off!', 'error')

    local alarmSound = GetSoundId()
    PlaySoundFromCoord(alarmSound, "Alarm_Loop", coords.x, coords.y, coords.z, "DLC_H3_FM_FIB_Raid_Sounds", true, 50, false)

    local dict = "scr_jewelheist"
    local particleName = "scr_jewel_cab_smash"

    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)
    local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    TriggerServerEvent('gs-vendrob:server:forceDispatchAlert', coords)

    Wait(10000)

    StopSound(alarmSound)
    ReleaseSoundId(alarmSound)
    StopParticleFxLooped(particleHandle, 0)
end)

RegisterNetEvent('gs-vendrob:client:breakTool', function()

    ShowNotification('Your ' .. Config.RequiredItem.Name .. ' broke!', 'error')

    PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)

    local playerPed = PlayerPedId()
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(playerPed, "anim@am_hold_up@male", "shoplift_mid", 8.0, -8.0, 1000, 0, 0, false, false, false)

    TriggerServerEvent('gs-vendrob:server:removeItem', Config.RequiredItem.Name)
end)

RegisterNetEvent('gs-vendrob:client:securityCamera', function()

    ShowNotification('A security camera spotted you!', 'error')

    PlaySoundFrontend(-1, "CCTV_BEEP", "LESTER1A_SOUNDS", true)

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local dict = "scr_bike_business"
    local particleName = "scr_bike_cfid_camera_flash"

    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)
    StartParticleFxNonLoopedAtCoord(particleName, coords.x, coords.y, coords.z + 2.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    TriggerServerEvent('gs-vendrob:server:forceDispatchAlert', coords)
end)

RegisterNetEvent('gs-vendrob:client:bonusReward', function()

    ShowNotification('You found a hidden compartment with extra cash!', 'success')

    PlaySoundFrontend(-1, "ROBBERY_MONEY_TOTAL", "HUD_FRONTEND_CUSTOM_SOUNDSET", true)

    TriggerServerEvent('gs-vendrob:server:giveBonusReward')
end)

RegisterNetEvent('gs-vendrob:client:breakMachine', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, GetHashKey('prop_vend_snak_01'), false, false, false)

    if not entity or entity == 0 then
        entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, GetHashKey('prop_vend_soda_01'), false, false, false)
    end

    if not entity or entity == 0 then
        entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, GetHashKey('prop_vend_soda_02'), false, false, false)
    end

    if entity and entity ~= 0 then

        ShowNotification('The vending machine broke down!', 'error')

        PlaySoundFromEntity(-1, "VEHICLES_HORNS_AMBULANCE_WARNING", entity, 0, 0, 0)

        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        end

        if NetworkGetEntityIsNetworked(entity) then
            local netId = NetworkGetNetworkIdFromEntity(entity)
            if netId ~= 0 then
                TriggerServerEvent('gs-vendrob:server:addBrokenMachine', netId)
            end
        end

        local dict = "core"
        local particleName = "ent_amb_smoke_factory_white"

        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Wait(0)
        end

        UseParticleFxAssetNextCall(dict)
        local particleHandle = StartParticleFxLoopedOnEntity(particleName, entity, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)

        Wait(10000)

        StopParticleFxLooped(particleHandle, 0)
    end
end)

RegisterNetEvent('gs-vendrob:client:blowUp', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local entity = nil
    local closestDist = 3.0
    local closestCoords = nil

    for _, model in pairs(Config.VendingMachines) do
        local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, model, false, false, false)
        if obj and obj ~= 0 then
            local objCoords = GetEntityCoords(obj)
            local dist = #(playerCoords - objCoords)
            if dist < closestDist then
                entity = obj
                closestDist = dist
                closestCoords = objCoords
            end
        end
    end

    if not entity or not closestCoords then return end

    ShowNotification('The vending machine is about to explode!', 'error')

    local dict = "core"
    local particleName = "exp_grd_bzgas_smoke"

    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(dict)
    local particleHandle = StartParticleFxLoopedAtCoord(particleName, closestCoords.x, closestCoords.y, closestCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    PlaySoundFromCoord(-1, "Beep_Red", closestCoords.x, closestCoords.y, closestCoords.z, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 20, false)

    Wait(2000)

    AddExplosion(closestCoords.x, closestCoords.y, closestCoords.z, 'EXPLOSION_STICKYBOMB', 0.5, true, true, 1.0)

    local health = GetEntityHealth(playerPed)
    local newHealth = math.max(100, health - 40) 
    SetEntityHealth(playerPed, newHealth)

    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)

    TriggerServerEvent('gs-vendrob:server:forceDispatchAlert', closestCoords)

    StopParticleFxLooped(particleHandle, 0)

    if entity and entity ~= 0 then

        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        end

        if NetworkGetEntityIsNetworked(entity) then
            local netId = NetworkGetNetworkIdFromEntity(entity)
            if netId ~= 0 then
                TriggerServerEvent('gs-vendrob:server:addBrokenMachine', netId)
            end
        end
    end
end)

function DrawTextOnScreen(text, x, y, scale, color)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

Citizen.CreateThread(function()

    Wait(1000)

    InitializeFramework()

    if Config.Debug then
        print('GS-VendRob: Random events system initialized')
    end
end)