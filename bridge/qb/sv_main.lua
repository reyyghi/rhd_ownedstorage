if not Framework.qb() then return end

local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('rhd_os:bridge:getqbpermissions', function( src, permission )
    if QBCore.Functions.HasPermission(src, permission) or IsPlayerAceAllowed(src, 'command') then
        return true
    end
    return false
end)

Framework.removeMoney = function ( src, type, amount )
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney(type, amount) then
        return true
    end
    return false
end

Framework.addMoney = function ( src, type, amount )
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.AddMoney( type, amount, '') then
        return true
    end
    return false
end

Framework.ServercId = function ( source )
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenId = Player.PlayerData.citizenid
    return citizenId
end

Framework.getPlayerFromCid = function ( cId )
    return QBCore.Functions.GetPlayerByCitizenId( cId )
end