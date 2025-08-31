

local QBCore = nil
local QBX = nil
local ESX = nil
local PlayerData = {}
local CurrentCops = 0

local GlobalCooldown = false
local MachinesCooldown = {}
local PlayerCooldown = false

local BrokenMachines = {}

local function InitializeFramework()
    if Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()

        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
        end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)

    elseif Config.Framework == 'qbx' then
        QBX = exports['qbx-core']:GetSharedObject()

        RegisterNetEvent('QBX:Client:OnPlayerLoaded', function()
            PlayerData = QBX.Functions.GetPlayerData()
        end)

        RegisterNetEvent('QBX:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)

    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerData.job = job
        end)
    end
end

local function InitializeTargetSystem()
    if Config.Target == 'qb' then

        for _, model in pairs(Config.VendingMachines) do
            exports['qb-target']:AddTargetModel(model, {
                options = {
                    {
                        type = "client",
                        event = "gs-vendrob:client:attemptRobbery",
                        icon = Config.TargetIcon,
                        label = "Rob Vending Machine",
                        canInteract = function(entity)
                            return not GlobalCooldown and not MachinesCooldown[entity] and not BrokenMachines[entity] and not PlayerCooldown
                        end
                    },
                },
                distance = 2.0
            })
        end
    elseif Config.Target == 'ox' then

        local options = {
            {
                name = 'gs_vendrob_rob',
                icon = Config.TargetIcon,
                label = 'Rob Vending Machine',
                onSelect = function(data)
                    TriggerEvent('gs-vendrob:client:attemptRobbery', data.entity)
                end,
                canInteract = function(entity, distance, coords, name, bone)
                    return not GlobalCooldown and not MachinesCooldown[entity] and not BrokenMachines[entity] and not PlayerCooldown
                end
            }
        }

        exports.ox_target:addModel(Config.VendingMachines, options)
    end
end

local function CheckPoliceCount()
    if not Config.RequirePolice then return true end

    if CurrentCops >= Config.MinPolice then
        return true
    else
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('Not enough police in the city', 'error')
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('Not enough police in the city', 'error')
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('Not enough police in the city')
        end
        return false
    end
end

local function CheckRequiredItem()
    local hasItem = false

    if Config.Framework == 'qbcore' then
        hasItem = QBCore.Functions.HasItem(Config.RequiredItem)
    elseif Config.Framework == 'qbx' then
        hasItem = QBX.Functions.HasItem(Config.RequiredItem)
    elseif Config.Framework == 'esx' then
        local inventory = ESX.GetPlayerData().inventory
        for i = 1, #inventory do
            if inventory[i].name == Config.RequiredItem and inventory[i].count > 0 then
                hasItem = true
                break
            end
        end
    end

    if not hasItem then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('You need a ' .. Config.RequiredItem, 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('You need a ' .. Config.RequiredItem, 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('You need a ' .. Config.RequiredItem)
        end
    end

    return hasItem
end

local function StartMinigame(entity)
    local success = false

    if Config.Minigame.Type == 'qb-lockpick' then

        local settings = Config.Minigame.Settings['qb-lockpick']
        success = exports['qb-lockpick']:StartLockPickCircle(
            settings.Pins, 
            settings.Time, 
            settings.Difficulty
        )
    elseif Config.Minigame.Type == 'ox-skillcheck' then

        local settings = Config.Minigame.Settings['ox-skillcheck']
        success = exports['ox_lib']:skillCheck(
            settings.Difficulty, 
            settings.Keys, 
            settings.SkillCheckCount
        )
    elseif Config.Minigame.Type == 'ox-circle' then

        local settings = Config.Minigame.Settings['ox-circle']
        success = exports['ox_lib']:circle(settings.Difficulty, settings.Duration)
    elseif Config.Minigame.Type == 'ox-bar' then

        local settings = Config.Minigame.Settings['ox-bar']
        success = exports['ox_lib']:progressBar({
            duration = settings.Duration,
            position = settings.Position,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped'
            },
            width = settings.Width,
        })
    elseif Config.Minigame.Type == 'ps-skillbar' then

        local settings = Config.Minigame.Settings['ps-skillbar']
        success = exports['ps-ui']:Skillbar(
            settings.Difficulty, 
            settings.SkillCheckCount
        )
    elseif Config.Minigame.Type == 'ps-circle' then

        local settings = Config.Minigame.Settings['ps-circle']
        success = exports['ps-ui']:Circle(
            settings.Duration,
            settings.Circles,
            settings.Success
        )
    elseif Config.Minigame.Type == 'ps-scrambler' then

        local settings = Config.Minigame.Settings['ps-scrambler']
        success = exports['ps-ui']:Scrambler(
            settings.Type,
            settings.Duration,
            settings.Length
        )
    end

    return success
end

local function HandleRandomEvent(success)

    if (success and not Config.RandomEvents.OnSuccess) or 
       (not success and not Config.RandomEvents.OnFail) then
        return
    end

    if math.random(1, 100) > Config.RandomEvents.Chance then return end

    local possibleEvents = {}
    local totalChance = 0

    if Config.RandomEvents.Events.Taze.Enabled then
        totalChance = totalChance + math.floor(Config.RandomEvents.Events.Taze.Chance)
        table.insert(possibleEvents, {
            name = 'taze',
            chance = totalChance
        })
    end

    if Config.RandomEvents.Events.BlowUp.Enabled then
        totalChance = totalChance + math.floor(Config.RandomEvents.Events.BlowUp.Chance)
        table.insert(possibleEvents, {
            name = 'blow_up',
            chance = totalChance
        })
    end

    if Config.RandomEvents.Events.SecurityCamera.Enabled then
        totalChance = totalChance + math.floor(Config.RandomEvents.Events.SecurityCamera.Chance)
        table.insert(possibleEvents, {
            name = 'security_camera',
            chance = totalChance
        })
    end

    if success and Config.RandomEvents.Events.BonusReward.Enabled then
        totalChance = totalChance + math.floor(Config.RandomEvents.Events.BonusReward.Chance)
        table.insert(possibleEvents, {
            name = 'bonus_reward',
            chance = totalChance
        })
    end

    if Config.RandomEvents.Events.Nothing.Enabled then
        totalChance = totalChance + math.floor(Config.RandomEvents.Events.Nothing.Chance)
        table.insert(possibleEvents, {
            name = 'nothing',
            chance = totalChance
        })
    end

    if #possibleEvents == 0 or totalChance <= 0 then return end

    local randomNum = math.random(1, totalChance)

    for _, event in pairs(possibleEvents) do
        if randomNum <= event.chance then

            TriggerServerEvent('gs-vendrob:server:triggerRandomEvent', event.name)
            return
        end
    end
end

local function SetCooldowns(entity)

    if Config.Cooldown.EnableGlobalCooldown then
        GlobalCooldown = true
        Citizen.SetTimeout(Config.Cooldown.GlobalCooldown * 60 * 1000, function()
            GlobalCooldown = false
        end)
    end

    MachinesCooldown[entity] = true
    Citizen.SetTimeout(Config.Cooldown.MachineCooldown * 60 * 1000, function()
        MachinesCooldown[entity] = nil
    end)

    if Config.Cooldown.EnablePlayerCooldown then
        PlayerCooldown = true
        Citizen.SetTimeout(Config.Cooldown.PlayerCooldown * 60 * 1000, function()
            PlayerCooldown = false
        end)
    end
end

local function AlertPolice(coords, forced)
    if not Config.AlertPolice then return end
    if not forced and math.random(1, 100) > Config.PoliceAlertChance then return end

    local streetName, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetLabel = GetStreetNameFromHashKey(streetName)

    if Config.Dispatch.System == 'ps' then

        if GetResourceState('ps-dispatch') == 'started' then

            local resourceMetadata = GetNumResourceMetadata('ps-dispatch', 'export')
            local hasExport = false

            for i = 0, resourceMetadata - 1 do
                local exportName = GetResourceMetadata('ps-dispatch', 'export', i)
                if exportName == 'VendingMachineRobbery' then
                    hasExport = true
                    break
                end
            end

            if hasExport then
                exports['ps-dispatch']:VendingMachineRobbery(coords)
            else

                TriggerServerEvent('gs-vendrob:server:alertPolice', {
                    coords = coords,
                    streetLabel = streetLabel
                })
            end
        else

            TriggerServerEvent('gs-vendrob:server:alertPolice', {
                coords = coords,
                streetLabel = streetLabel
            })
        end
    elseif Config.Dispatch.System == 'cd' then

        local data = {
            displayCode = '10-31',
            description = 'Vending Machine Robbery',
            isImportant = true,
            recipientList = {'police'},
            length = '10000',
            infoM = 'fa-info-circle',
            info = 'Vending Machine Robbery at ' .. streetLabel
        }
        local dispatchData = {
            dispatchData = data,
            caller = 'Concerned Citizen',
            coords = coords
        }
        TriggerServerEvent('cd_dispatch:AddNotification', dispatchData)
    else

        TriggerServerEvent('gs-vendrob:server:alertPolice', {
            coords = coords,
            streetLabel = streetLabel
        })
    end
end

local function RobVendingMachine(entity)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)

    TaskTurnPedToFaceEntity(playerPed, entity, 500)
    Wait(500)

    local function StartRobbery()

        local success = StartMinigame(entity)

        if success then

            TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
            Wait(2000)
            ClearPedTasks(playerPed)

            TriggerServerEvent('gs-vendrob:server:rewardPlayer', entityCoords)

            HandleRandomEvent(true)

            AlertPolice(entityCoords)

            SetCooldowns(entity)

            TriggerServerEvent('gs-vendrob:server:removeItem', Config.RequiredItem)
        else

            if Config.Framework == 'qbcore' then
                QBCore.Functions.Notify('You failed to break into the vending machine', 'error', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'qbx' then
                QBX.Functions.Notify('You failed to break into the vending machine', 'error', Config.NotifyDuration * 1000)
            elseif Config.Framework == 'esx' then
                ESX.ShowNotification('You failed to break into the vending machine')
            end

            HandleRandomEvent(false)

            if Config.AlertPoliceOnCancel then
                AlertPolice(entityCoords)
            end
        end
    end

    if Config.ProgressBar.Enabled then
        if Config.ProgressBar.Type == "ox_progressbar" then

            local options = Config.ProgressBar.Options["ox_progressbar"]
            if exports['ox_lib']:progressBar(options) then
                StartRobbery()
            else

                if Config.AlertPoliceOnCancel then
                    AlertPolice(entityCoords)
                end
            end
        elseif Config.ProgressBar.Type == "ox_progresscircle" then

            local options = Config.ProgressBar.Options["ox_progresscircle"]
            if exports['ox_lib']:progressCircle(options) then
                StartRobbery()
            else

                if Config.AlertPoliceOnCancel then
                    AlertPolice(entityCoords)
                end
            end
        elseif Config.ProgressBar.Type == "qb_progressbar" then

            local options = Config.ProgressBar.Options["qb_progressbar"]
            if Config.Framework == 'qbcore' then
                QBCore.Functions.Progressbar(options.name, options.label, options.duration, options.useWhileDead, options.canCancel, options.controlDisables, options.animation, {}, {}, function()

                    StartRobbery()
                end, function()

                    if Config.AlertPoliceOnCancel then
                        AlertPolice(entityCoords)
                    end
                end)
            elseif Config.Framework == 'qbx' then
                QBX.Functions.Progressbar(options.name, options.label, options.duration, options.useWhileDead, options.canCancel, options.controlDisables, options.animation, {}, {}, function()

                    StartRobbery()
                end, function()

                    if Config.AlertPoliceOnCancel then
                        AlertPolice(entityCoords)
                    end
                end)
            else

                StartRobbery()
            end
        else

            StartRobbery()
        end
    else

        StartRobbery()
    end
end

RegisterNetEvent('gs-vendrob:client:attemptRobbery', function(entity)

    if not entity or not DoesEntityExist(entity) then return end

    if GlobalCooldown then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('You need to wait before robbing another vending machine', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('You need to wait before robbing another vending machine', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('You need to wait before robbing another vending machine')
        end
        return
    end

    if MachinesCooldown[entity] then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('This vending machine was recently robbed', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('This vending machine was recently robbed', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('This vending machine was recently robbed')
        end
        return
    end

    if IsMachineBroken(entity) then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('This vending machine is broken', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('This vending machine is broken', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('This vending machine is broken')
        end
        return
    end

    if PlayerCooldown then
        if Config.Framework == 'qbcore' then
            QBCore.Functions.Notify('You need to wait before robbing another vending machine', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'qbx' then
            QBX.Functions.Notify('You need to wait before robbing another vending machine', 'error', Config.NotifyDuration * 1000)
        elseif Config.Framework == 'esx' then
            ESX.ShowNotification('You need to wait before robbing another vending machine')
        end
        return
    end

    if not CheckPoliceCount() then return end

    if not CheckRequiredItem() then return end

    RobVendingMachine(entity)
end)

RegisterNetEvent('gs-vendrob:client:getTazed', function()
    local playerPed = PlayerPedId()

    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify('You got shocked by the vending machine!', 'error')
    elseif Config.Framework == 'qbx' then
        QBX.Functions.Notify('You got shocked by the vending machine!', 'error')
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification('You got shocked by the vending machine!')
    end

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

    Wait(5000)

    StopParticleFxLooped(particleHandle, 0)
    DeleteEntity(prop)
end)

RegisterNetEvent('gs-vendrob:client:triggerAlarm', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify('The vending machine alarm went off!', 'error')
    elseif Config.Framework == 'qbx' then
        QBX.Functions.Notify('The vending machine alarm went off!', 'error')
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification('The vending machine alarm went off!')
    end

    local alarmSound = CreateDui("https://www.youtube.com/embed/ZKMItSrWiEI?autoplay=1&controls=0&showinfo=0&autohide=1", 1, 1)

    AlertPolice(coords)

    Wait(10000)

    DestroyDui(alarmSound)
end)

RegisterNetEvent('gs-vendrob:client:breakTool', function()

    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify('Your ' .. Config.RequiredItem.Name .. ' broke!', 'error')
    elseif Config.Framework == 'qbx' then
        QBX.Functions.Notify('Your ' .. Config.RequiredItem.Name .. ' broke!', 'error')
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification('Your ' .. Config.RequiredItem.Name .. ' broke!')
    end

    TriggerServerEvent('gs-vendrob:server:removeItem', Config.RequiredItem.Name)
end)

RegisterNetEvent('gs-vendrob:client:updatePoliceCount', function(count)
    CurrentCops = count
end)

Citizen.CreateThread(function()

    Wait(1000)

    InitializeFramework()

    InitializeTargetSystem()

    if Config.Debug then
        print('GS-VendRob: Client initialized')
    end
end)

Citizen.CreateThread(function()
    while true do
        TriggerServerEvent('gs-vendrob:server:updatePoliceCount')
        Wait(60000) 
    end
end)