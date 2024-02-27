local newstash = require "data.stash"

RegisterCommand("migratestash", function (_)
    local oldFile = LoadResourceFile(GetCurrentResourceName(), "data/stash-old.json")
    local oldStash = json.decode(oldFile)
    
    local newData = {}
    for i=1, #oldStash do
        local oldData = oldStash[i]

        local rentIdentifier = {}

        if oldStash.rentalData and #oldStash.rentalData > 0 then
            for a=1, #oldStash.rentalData do
                local oldrd = oldStash.rentalData[a]
                rentIdentifier[oldrd.identifier] = oldrd.date
            end
        end

        newData[oldData.id] = {
            id = oldData.id,
            label = oldData.label,
            slots = oldData.slots,
            weight = oldData.weight,
            owned = true,
            coords = vec(oldData.lokasi.x, oldData.lokasi.y, oldData.lokasi.z),
            rentalData = {
                price = oldData.rentalPrice,
                identifier = rentIdentifier
            },
        }
    end

    lib.table.merge(newstash, newData)

    Storage.save(newstash, function (sucscess, newData)
        if not sucscess then return end
        TriggerClientEvent('rhd_os:client:loadstashdata', -1, newData)
    end, 'update')
end, false)