Storage = {}

local stash = require 'data.stash'

function Storage.getData()
    return stash
end

function Storage.save(stashData, cb, methode)
    local newData = {}
    
    if methode == "create" then
        if stash[stashData.id] then return
            cb and cb(false, {}) or false, {}
        end
    
        stash[stashData.id] = stashData
        RB.i.registerStash(stashData)
    end

    local stashFormat = [[
    ["%s"] = {
        id = "%s",
        label = "%s",
        slots = %d,
        weight = %d,
        owned = %s,
        groups = %s,
        coords = vec(%.2f, %.2f, %.2f, %.2f),
        prop = "%s",
        rentalData = %s,
    },
]]


    for k, v in pairs(stash) do

        local groups = nil
        if v.groups and type(v.groups) == "table" and next(v.groups) then
            local gt, gf, gd = '{%s}', [[%s = %d]], {}
            for name, grade in pairs(v.groups) do
                gd[#gd+1] = gf:format(name, grade)
            end
            gt = gt:format(table.concat(gd, ', '))
            groups = gt:format(gt)
        end

        local rentalData = nil
        if v.rentalData and type(v.rentalData) == "table" then
            local rdf = [[{
            price = %d,
            identifier = {%s}
        }]]

            local rf, rd = [[["%s"] = "%s"]], {}
            for cid, date in pairs(v.rentalData.identifier) do
                rd[#rd+1] = rf:format(cid, date)
            end
            rentalData = rdf:format(v.rentalData.price, table.concat(rd, ', '))
        end

        newData[#newData+1] = stashFormat:format(
            v.id,
            v.id,
            v.label,
            v.slots,
            v.weight,
            v.owned,
            groups,
            v.coords.x,
            v.coords.y,
            v.coords.z,
            v.coords.w or 0.0,
            v.prop,
            rentalData
        ):gsub('[%s]-[%w]+ = "?nil"?,?', '')
        
    end

    local resultsFormat = [[
return {
%s
}
]]

    local results = resultsFormat:format(table.concat(newData, ""))
    SaveResourceFile(GetCurrentResourceName(), 'data/stash.lua', results, -1)

    return cb and cb(true, stash) or true, stash
end