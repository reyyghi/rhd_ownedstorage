if GetResourceState('qb-core') ~= 'started'  then return end

print('QBCore Loaded')

local PlayerData = {}
local QBCore = exports['qb-core']:GetCoreObject()

function RB.f.getMoney(type)
    return PlayerData.money?[type] or 0
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)