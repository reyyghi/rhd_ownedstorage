RHD.Fungsi = {}
RHD.Storage = {}

RHD.Fungsi.saveFile = function ()
    SaveResourceFile(GetCurrentResourceName(), 'data/storage.json', json.encode(RHD.Storage))
end

RHD.Fungsi.notify = function ( msg, type, duration )
    lib.notify(source, {
        description = msg,
        type = type,
        duration = duration
    })
end

CreateThread(function()
    RHD.Storage = {}
    local loadFile = LoadResourceFile(GetCurrentResourceName(), 'data/storage.json')
    if loadFile then
        RHD.Storage = json.decode(loadFile)
        Wait(10)
        if not RHD.Storage then
            RHD.Storage = {}
        end
    else
        RHD.Storage = {}
    end

    Wait(100)
    if RHD.Storage and #RHD.Storage > 0 then
        for i=1, #RHD.Storage do
            local storage = RHD.Storage[i]
            TriggerClientEvent('rhd_os:rhd_os:loadTarget', -1, storage)
            
            if Framework.ox_inventory() then
                exports.ox_inventory:RegisterStash(storage.id, storage.label, storage.slots, storage.weight, true)
            end
        end
    end
end)


AddEventHandler('txAdmin:events:serverShuttingDown', function() 
    RHD.Fungsi.saveFile()
end)

AddEventHandler('onResourceStop', function(ResourceName) if ResourceName == GetCurrentResourceName() then
    RHD.Fungsi.saveFile()
end end)
