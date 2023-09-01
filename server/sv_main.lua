local Esx = exports.es_extended:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    if RHD.Storage and #RHD.Storage > 0 then
        for i=1, #RHD.Storage do
            local storage = RHD.Storage[i]
            xPlayer.triggerEvent('rhd_os:rhd_os:loadTarget', storage)
        end
    end
end)

RegisterNetEvent('rhd_os:registerNewStorage', function ( storageData )
    if RHD.Storage and #RHD.Storage > 0 then
        local storage = RHD.Storage
        for i=1, #storage do
            if storage[i].id == storageData.id then
                table.remove(storage, i)
            end
        end
    end

    RHD.Storage[#RHD.Storage+1] = storageData
    exports.ox_inventory:RegisterStash(storageData.id, storageData.label, storageData.slots, storageData.weight, true)
    TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, storageData)
end)

RegisterNetEvent('rhd_os:rentStorage', function( id, rentalId, data )

    local nextTime = os.time() + (3 * 24 * 60 * 60)

    if RHD.Storage[id].rentalData and #RHD.Storage[id].rentalData > 0 then
        if #RHD.Storage[id].rentalData[rentalId] then
            table.remove(RHD.Storage[id].rentalData, rentalId)
        end
    end

    RHD.Storage[id].rentalData[#RHD.Storage[id].rentalData+1] = {
        identifier = Player(source).state.identifier,
        date = os.date('%d-%m-%Y', nextTime)
    }

    exports.ox_inventory:RemoveItem(source, 'money', tonumber(data.rentalPrice))
    TriggerClientEvent('rhd_os:rhd_os:loadTarget', source, data)
end)

RegisterNetEvent('rhd_os:removeCurrentStorage', function( listId , stashId )
    if RHD.Storage and #RHD.Storage > 0 then
        table.remove(RHD.Storage, listId)
        TriggerClientEvent('rhd_os:removeCurrentTarget', -1, stashId)
        
        exports.ox_inventory:ClearInventory(stashId)
        print(stashId, 'Removed')
        MySQL.query('delete from ox_inventory where name = ?', {tostring(stashId)})
    end
end)

RegisterNetEvent('rhd_os:buyStorage', function( sId, tData )
    if RHD.Storage and #RHD.Storage > 0 then
        RHD.Storage[sId].owner = Player(source).state.identifier
        RHD.Storage[sId].forsale = false

        tData.owner = Player(source).state.identifier
        tData.forsale = false

        exports.ox_inventory:RemoveItem(source, 'money', tData.salePrice)

        if tData.owner then
            local playerOnline = Esx.GetPlayerFromIdentifier(tData.owner)
            if playerOnline and playerOnline ~= nil then
                playerOnline.addAccountMoney('bank', tData.salePrice, '')
            else
                MySQL.query('select accounts from users where identifier like "%' .. tData.owner .. '%"', {}, function (accounts)
                    if accounts[1] ~= nil then
                        for k, v in pairs(accounts) do
                            local money = json.decode(v.accounts)
            
                            local updateData = {
                                money = money.money,
                                bank = tonumber(tData.salePrice),
                                black_money = money.black_money
                            }
                            
                            MySQL.update('update users set accounts = ? where identifier = ?', {json.encode(updateData), tData.owner})
                        end
                    end
                end)
            end
        end

        TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, tData)
    end
end)

RegisterNetEvent('rhd_os:withdraw', function( sId, amount )
    if RHD.Storage and #RHD.Storage > 0 then
        RHD.Storage[sId].money -= amount
        exports.ox_inventory:AddItem(source, 'money', amount)
    end
end)

RegisterNetEvent('rhd_os:setstorage', function( sId, storageData, refresh )
    if RHD.Storage and #RHD.Storage > 0 then
        RHD.Storage[sId] = storageData
        exports.ox_inventory:RegisterStash(storageData.id, storageData.label, storageData.slots, storageData.weight, true)

        if refresh then
            TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, storageData)
        end
    end
end)

--- Server Callback
lib.callback.register('rhd_os:cb:getRentalData', function ( src )
    if RHD.Storage and #RHD.Storage > 0 then
        return RHD.Storage
    end
    return false
end)

lib.callback.register('rhd_os:cb:cekRentalTime', function ( src, rentDate )
    if os.date('%d-%m-%Y') < rentDate then
        return false
    end
    return true
end)


--- Admin Commands
lib.addCommand(locale('admin_command:name:create.new_storage'), {
    help = locale('admin_command:label:create.new_storage'),
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent('rhd_os:createnNew', source)
end)