if GetResourceState('ox_target') ~= 'started' then return end

local target = exports.ox_target

local st = {}

function RB.t.addTarget(index, val)
    local opt = {}
    
    if st[index] then
        target:removeZone(st[index])
    end

    if val.opt then
        for i=1, #val.opt do
            local td = val.opt[i]
            opt[#opt+1] = {
                label = td.label,
                icon = td.icon,
                onSelect = function ()
                    return td.func()
                end,
                groups = td.groups,
                distance = td.dist,
            }
        end
    end

    st[index] = target:addSphereZone({
        coords = val.loc,
        radius = val.rad,
        options = opt
    })
end