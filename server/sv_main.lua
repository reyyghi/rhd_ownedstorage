
RegisterNetEvent('rhd_os:server:createstash', function(stashData)
    Storage.save(stashData, function (success)
        if not success then
            return RB.n.send(source, ('Stash dengan id %s sudah tersedia !'):format(stashData.id), 'error', 8000)
        end

        RB.n.send(source, 'Stash berhasil di buat !', 'success', 8000)
    end)
end)