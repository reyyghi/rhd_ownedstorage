if GetResourceState('ox_inventory') ~= 'started' then return end

local isServer = IsDuplicityVersion()
local inventory = exports.ox_inventory

function RB.i.openStash(id)
    return inventory:openInventory('stash', id)
end

if isServer then
    function RB.i.registerStash(stashData)
        inventory:RegisterStash(stashData.id, stashData.label, stashData.slots, stashData.weight, stashData.owned)
    end
end