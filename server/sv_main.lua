
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

    if RHD.inv == 'ox_inventory' then
        exports.ox_inventory:RegisterStash(storageData.id, storageData.label, storageData.slots, storageData.weight, true)
    end

    TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, storageData)
end)

RegisterNetEvent('rhd_os:rentStorage', function( id, rentalId, data, day )

    local nextTime = os.time() + (day * 24 * 60 * 60)

    if RHD.Storage[id].rentalData and #RHD.Storage[id].rentalData > 0 then
        if #RHD.Storage[id].rentalData[rentalId] then
            table.remove(RHD.Storage[id].rentalData, rentalId)
        end
    end

    print(Framework.ServercId(source))
    RHD.Storage[id].rentalData[#RHD.Storage[id].rentalData+1] = {
        identifier = Framework.ServercId(source),
        date = os.date('%d-%m-%Y', nextTime)
    }

    if RHD.inv == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(source, 'money', tonumber(data.rentalPrice))
    else
        Framework.removeMoney(source, 'cash', tonumber(data.rentalPrice))
    end

    TriggerClientEvent('rhd_os:rhd_os:loadTarget', source, data)
end)

RegisterNetEvent('rhd_os:removeCurrentStorage', function( listId , stashId )
    if RHD.Storage and #RHD.Storage > 0 then
        table.remove(RHD.Storage, listId)
        TriggerClientEvent('rhd_os:removeStorage', -1, stashId)
        
        if RHD.inv == 'ox_inventory' then
            exports.ox_inventory:ClearInventory(stashId)
            MySQL.query('delete from ox_inventory where name = ?', {tostring(stashId)})
        else
            MySQL.query('delete from stashitems where stash like "%' .. stashId ..'_%"')
        end

        print(stashId, 'Removed')
    end
end)

RegisterNetEvent('rhd_os:buyStorage', function( sId, tData )
    if RHD.Storage and #RHD.Storage > 0 then
        RHD.Storage[sId].owner = Framework.ServercId(source)
        RHD.Storage[sId].forsale = false

        tData.owner = Framework.ServercId(source)
        tData.forsale = false

        if RHD.inv == 'ox_inventory' then
            exports.ox_inventory:RemoveItem(source, 'money', tonumber(tData.salePrice))
        else
            Framework.removeMoney(source, 'cash', tonumber(tData.salePrice))
        end

        if tData.owner then
            local playerOnline = Framework.getPlayerFromCid(tData.owner)
            if playerOnline and playerOnline ~= nil then
                Framework.addMoney(source, 'bank', tData.salePrice)
            else
                Framework.addMoneyFromDB('bank', tData.salePrice)
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
        
        if RHD.inv == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(storageData.id, storageData.label, storageData.slots, storageData.weight, true)
        end
        
        if refresh then
            TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, storageData)
        end
    end
end)

--- Server Callback
lib.callback.register('rhd_os:cb:getStorageData', function ( src )
    if RHD.Storage and #RHD.Storage > 0 then
        return RHD.Storage
    end
    return false
end)

lib.callback.register('rhd_os:cb:cekRentalTime', function ( src, rentDate )
    if os.date('%d-%m-%Y') < rentDate then
        return true
    end
    return false
end)


--- Admin Commands
lib.addCommand(locale('admin_command:name:create.new_storage'), {
    help = locale('admin_command:label:create.new_storage'),
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent('rhd_os:createnNew', source)
end)
