if GetResourceState('es_extended') ~= 'started' then return end

print('ESX Loaded')

local PlayerData = {}
local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx:setPlayerData', function(key, val, current)
    PlayerData[key] = val
end)
