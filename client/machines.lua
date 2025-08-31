

BrokenMachines = {}

RegisterNetEvent('gs-vendrob:client:updateBrokenMachines', function(machines)
    BrokenMachines = machines

    if Config.Debug then
        local count = 0
        for _ in pairs(BrokenMachines) do
            count = count + 1
        end
        print('GS-VendRob: Received ' .. count .. ' broken machines')
    end
end)

function IsMachineBroken(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    if not NetworkGetEntityIsNetworked(entity) then
        NetworkRegisterEntityAsNetworked(entity)
    end

    local netId = 0
    if NetworkGetEntityIsNetworked(entity) then
        netId = NetworkGetNetworkIdFromEntity(entity)
    else
        return false 
    end

    return BrokenMachines[netId] == true
end

Citizen.CreateThread(function()

    Wait(2000)

    TriggerServerEvent('gs-vendrob:server:getBrokenMachines')
end)