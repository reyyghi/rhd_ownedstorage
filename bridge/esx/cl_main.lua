if not Framework.esx() then return end

local ESX = exports.es_extended:getSharedObject()

Framework.myGroup = function ( groupName )
    return LocalPlayer.state.group == groupName
end

Framework.cekMoney = function ( type, amount )
    type = type or 'cash'
    if type == 'cash' then type = 'money' end

    local ac = ESX.GetPlayerData().accounts

    local money = nil
    for i=1, #ac do
        local data = ac[i]
        money = data.name == type and data.money
        if money then
            return money >= amount
        end
    end

    return false
end

Framework.cId = function ()
    return LocalPlayer.state.identifier
end

Framework.pName = function ()
    return LocalPlayer.state.name
end


--- Event
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    local storage = lib.callback.await('rhd_os:cb:getStorageData', false)
    if not storage then return end
    
    for i=1, #storage do
        local data = storage[i]
        TriggerEvent('rhd_os:rhd_os:loadTarget', data)
    end
end)