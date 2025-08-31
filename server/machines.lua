

local BrokenMachines = {}

RegisterNetEvent('gs-vendrob:server:addBrokenMachine', function(netId)
    local source = source

    if not source then return end

    BrokenMachines[netId] = true

    TriggerClientEvent('gs-vendrob:client:updateBrokenMachines', -1, BrokenMachines)

    if Config.Debug then
        print('GS-VendRob: Machine ' .. netId .. ' marked as broken')
    end

    Citizen.SetTimeout(Config.Cooldown.MachineCooldown * 60 * 1000 * 2, function() 
        BrokenMachines[netId] = nil
        TriggerClientEvent('gs-vendrob:client:updateBrokenMachines', -1, BrokenMachines)

        if Config.Debug then
            print('GS-VendRob: Machine ' .. netId .. ' repaired')
        end
    end)
end)

RegisterNetEvent('gs-vendrob:server:getBrokenMachines', function()
    local source = source

    if not source then return end

    TriggerClientEvent('gs-vendrob:client:updateBrokenMachines', source, BrokenMachines)
end)

AddEventHandler('playerJoined', function()
    local source = source

    TriggerClientEvent('gs-vendrob:client:updateBrokenMachines', source, BrokenMachines)
end)