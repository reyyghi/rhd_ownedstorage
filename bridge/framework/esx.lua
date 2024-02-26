if GetResourceState('es_extended') ~= 'started' then return end

print('ESX Loaded')

local PlayerData = {}
local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('esx:setPlayerData', function(key, val, current)
    PlayerData[key] = val
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    PlayerData = xPlayer
    RB.pl = true
end)