
lib.callback.register('rhd_os:server:checkrentaldate', function(_, rentalDate)
    local cd = os.time()

    local year = tonumber(rentalDate:sub(7, 10))
    local month = tonumber(rentalDate:sub(4, 5))
    local day = tonumber(rentalDate:sub(1, 2))
    local rentalTimestamp = os.time{year = year, month = month, day = day, hour = 0}

    return rentalTimestamp > cd
end)

RegisterNetEvent('rhd_os:server:createstash', function(stashData)
    Storage.save(stashData, function (sucscess, newData)
        if not sucscess then
            return RB.n.send(source, ('Stash dengan id %s sudah tersedia !'):format(stashData.id), 'error', 8000)
        end
        
        TriggerClientEvent('rhd_os:client:loadstashdata', -1, newData)
        RB.n.send(source, 'Stash berhasil di buat !', 'success', 8000)
    end, 'create')
end)

RegisterNetEvent('rhd_os:server:rentstash', function(data)
    local stash = Storage.getData()
    local price = data.price * data.day
    if RB.f.removeBank(source, price) then
        local ws = os.time()
        local tw = data.day * (24 * 60 * 60)
        ws += tw
        local tgl = os.date('%d/%m/%Y', ws)
        
        stash[data.id].rentalData.identifier[data.identifier] = tgl
        Storage.save(stash, function (sucscess, newData)
            if not sucscess then return end
            TriggerClientEvent('rhd_os:client:syncData', -1, newData)
            RB.n.send(source, "Berhasil menyewa stash", "success", 8000)
        end, 'update')
    end
end)