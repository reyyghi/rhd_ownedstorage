if not Framework.qb() then return end

local QBCore = exports['qb-core']:GetCoreObject()

Framework.myGroup = function ( groupName )
    return lib.callback.await('rhd_os:bridge:getqbpermissions', false, groupName)
end

Framework.cekMoney = function ( type, amount )
    local money = QBCore.Functions.GetPlayerData().money[type]
    if money then
        return money >= amount
    end
    return false
end

Framework.cId = function ()
    return QBCore.Functions.GetPlayerData().citizenid
end

Framework.pName = function ()
    local charinfo = QBCore.Functions.GetPlayerData().charinfo
    return string.format('%s %s', charinfo.firstname, charinfo.lastname)
end

--- Event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local storage = lib.callback.await('rhd_os:cb:getStorageData', false)
    if not storage then return end
    
    for i=1, #storage do
        local data = storage[i]
        TriggerEvent('rhd_os:rhd_os:loadTarget', data)
    end
end)