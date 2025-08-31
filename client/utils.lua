

function DebugPrint(message)
    if Config.Debug then
        print('[GS-VendRob] ' .. message)
    end
end

function GetClosestVendingMachine()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestMachine = nil
    local closestDistance = 999.0

    for _, model in pairs(Config.VendingMachines) do

        local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, model, false, false, false)

        if DoesEntityExist(object) then
            local objectCoords = GetEntityCoords(object)
            local distance = #(playerCoords - objectCoords)

            if distance < closestDistance then
                closestMachine = object
                closestDistance = distance
            end
        end
    end

    return closestMachine, closestDistance
end

function IsEntityVendingMachine(entity)
    if not DoesEntityExist(entity) then return false end

    local model = GetEntityModel(entity)

    for _, machineModel in pairs(Config.VendingMachines) do
        if model == machineModel then
            return true
        end
    end

    return false
end

function FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60

    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function Draw3DText(x, y, z, text)

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then

        local dist = #(GetGameplayCamCoords() - vector3(x, y, z))
        local scale = 1.8 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)

        AddTextComponentString(text)
        DrawText(_x, _y)

        local factor = string.len(text) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

function PlayAnimation(dict, anim, duration)
    local playerPed = PlayerPedId()

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, duration, 0, 0, false, false, false)

    Wait(duration)

    ClearPedTasks(playerPed)
end

function LoadModel(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end

    if not IsModelValid(model) then
        return false
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    return true
end

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    return true
end

function GetStreetName(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)

    if crossingHash ~= 0 then
        local crossingName = GetStreetNameFromHashKey(crossingHash)
        return streetName .. ' & ' .. crossingName
    end

    return streetName
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

function IsPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

function IsPlayerHandcuffed()
    return IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3)
end

function IsPlayerDead()
    return IsEntityDead(PlayerPedId())
end

function CanPlayerRob()
    return not IsPlayerInVehicle() and not IsPlayerHandcuffed() and not IsPlayerDead()
end

function ShowHelpText(text, duration)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

function ShowFloatingHelpText(text, coords)
    AddTextEntry('FloatingHelpNotification', text)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end