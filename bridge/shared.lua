Framework = {}

Framework.esx = function ()
    return GetResourceState('es_extended') ~= 'missing'
end

Framework.qb = function ()
    return GetResourceState('qb-core') ~= 'missing'
end

Framework.ox_inventory = function ()
    return GetResourceState('ox_inventory') ~= 'missing'
end