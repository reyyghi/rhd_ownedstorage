Storage = {}

local stash = require 'data.stash'

function Storage.getData()
    return stash
end

function Storage.save(stashData, cb)
    local newData = {}
    
    if stash[stashData.id] then return
        cb and cb(false) or false
    end

    stash[stashData.id] = stashData
    RB.i.registerStash(stashData)

    local stashFormat = [[
    ["%s"] = {
        id = "%s",
        label = "%s",
        slots = %d,
        weight = %d,
        coords = vec(%.2f, %.2f, %.2f, %.2f),
        prop = "%s"
    },
]]

    for k, v in pairs(stash) do
        newData[#newData+1] = stashFormat:format(
            v.id,
            v.id,
            v.label,
            v.slots,
            v.weight,
            v.coords.x,
            v.coords.y,
            v.coords.z,
            v.coords.w or 0.0,
            v.prop
        ):gsub('[%s]-[%w]+ = "?nil"?,?', '')
    end

    local resultsFormat = [[
return {
%s
}
]]

    TriggerClientEvent('rhd_os:client:loadstashdata', -1, stash)
    local results = resultsFormat:format(table.concat(newData, ""))
    SaveResourceFile(GetCurrentResourceName(), 'data/stash.lua', results, -1)
end