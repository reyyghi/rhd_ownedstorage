
local sp = {}
local stash = require 'data.stash'

RegisterNetEvent('rhd_os:client:createstash', function()
    local input = lib.inputDialog('Pembuatan Gudang', {
        { type = 'input', label = 'Id', placeholder = 'gudang_baru', required = true, min = 1 },
        { type = 'input', label = 'Label', placeholder = 'Gudang Baru', required = true, min = 1},
        { type = 'number', label = 'Weight', required = true, min = 1 },
        { type = 'number', label = 'Slots', required = true, min = 1 },
        { type = 'checkbox', label = 'Owned' },
        { type = 'checkbox', label = 'Use Prop' },
    })
    
    if input then
        local i = input
        local pakaiProp = input[6]

        local data = {
            id = i[1]:gsub("%s+", ""),
            label = i[2],
            weight = i[3],
            slots = i[4],
            prop = nil,
            coords = nil,
            owned = input[5]
        }

        if pakaiProp then
            local propData = Placer.start()
            if not propData then return print("Error ") end
            data.coords = propData.coords
            data.prop = propData.model
        else
            local laserData = Laser.start()
            if not laserData then return print("Error ") end
            data.coords = laserData.coords
        end

        TriggerServerEvent("rhd_os:server:createstash", data)
    end
end)

RegisterNetEvent('rhd_os:client:loadstashdata', function(stashData)
    local stashData = stashData or stash
    for id, data in pairs(stashData) do

        if data.prop then
            lib.requestModel(data.prop, 1500)
            sp[id] = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z, false, false, false)
            PlaceObjectOnGroundProperly(sp[id])
            SetEntityHeading(sp[id],  data.coords.w)
            FreezeEntityPosition(sp[id], true)

            data.coords.z += 1
        end

        RB.t.addTarget(id, {
            loc = data.coords.xyz,
            rad = 0.5,
            opt = {
                {
                    label = data.label,
                    icon  = "fas fa-warehouse",
                    func = function ()
                        RB.i.openStash(id)
                    end,
                    dist = 1.5
                }
            }
        })
    end
end)

CreateThread(function ()
    if LocalPlayer.state.isLoggedIn then
        TriggerEvent('rhd_os:client:loadstashdata')
    end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
      for id, entity in pairs(sp) do
        DeleteEntity(entity)
      end
   end
end)