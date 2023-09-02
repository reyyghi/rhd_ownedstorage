if not Framework.esx() then return end

local ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    TriggerEvent('rhd_os:Framework:loadPlayer', xPlayer.source)
end)

Framework.removeMoney = function ( src, type, amount )
    type = type or 'cash'
    if type == 'cash' then type = 'money' end
    amount = amount or 0
    local Player = ESX.GetPlayerFromId(src)
    local money = Player.getAccount(type).money
    if money >= amount then
        Player.removeAccountMoney(type, amount, '')
        return true
    end
    return false
end

Framework.addMoney = function ( src, type, amount )
    type = type or 'cash'
    if type == 'cash' then type = 'money' end
    amount = amount or 0
    local Player = ESX.GetPlayerFromId(src)
    Player.addAccountMoney(type, amount, '')
end

Framework.ServercId = function ( source )
    return Player(source).state.identifier
end

Framework.getPlayerFromCid = function ( cId )
    return ESX.GetPlayerFromIdentifier(cId)
end

Framework.addMoneyFromDB = function ( type, amount )
    type = type or 'cash'
    if type == 'cash' then type = 'money' end
    amount = amount or 0

    MySQL.query('select accounts from users where identifier like "%' .. tData.owner .. '%"', {}, function (accounts)
        if accounts[1] ~= nil then
            for k, v in pairs(accounts) do
                local money = json.decode(v.accounts)

                local updateData = {
                    money = money.money,
                    bank = money.bank,
                    black_money = money.black_money
                }

                if type == 'money' then
                    updateData.money += amount
                elseif type == 'bank' then
                    updateData.bank += amount
                else
                    return
                end
                
                MySQL.update('update users set accounts = ? where identifier = ?', {json.encode(updateData), tData.owner})
            end
        end
    end)
end