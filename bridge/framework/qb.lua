if GetResourceState('qb-core') ~= 'started'  then return end

print('QBCore Loaded')

local PlayerData = {}
local QBCore = exports['qb-core']:GetCoreObject()
local isServer = IsDuplicityVersion()

function RB.f.getMoney(type)
    return PlayerData.money?[type] or 0
end

function RB.f.getIdentifier()
    return PlayerData.citizenid
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    RB.pl = true
end)

if isServer then
    function RB.f.removeBank(source, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.Functions.RemoveMoney('bank', amount, '')
    end

    function RB.f.getIdentifier(source)
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.citizenid
    end
end