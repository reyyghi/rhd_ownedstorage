
local sp = {}
local stash = require 'data.stash'

local function getData(st)
    local result = promise.new()
    local st = st
    CreateThread(function ()
        local data = {}
        if st == 'business' then
            local input = lib.inputDialog('Business Setting', {
                { type = 'number', label = 'Rental Price', placeholder = '$', required = true, min = 1},
            })

            if input then
                data = {
                    rentalData = {
                        price = input[1],
                        identifier = {}
                    }
                }
            end
        elseif st == "job" then
            local input = lib.inputDialog('Jobs Setting', {
                { type = 'input', label = 'Job Name', placeholder = 'police', required = true, min = 1 },
                { type = 'number', label = 'Job Rank', required = true, min = 1}
            })
            
            if input then
                data = {
                    groups = {[input[1]] = input[2]}
                }
            end
        end
        result:resolve(data)
    end)
    return result
end

RegisterNetEvent('rhd_os:client:createstash', function()
    local input = lib.inputDialog('Stash Creator', {
        { type = 'input', label = 'Id', placeholder = 'gudang_baru', required = true, min = 1 },
        { type = 'input', label = 'Label', placeholder = 'Gudang Baru', required = true, min = 1},
        { type = 'number', label = 'Weight', required = true, min = 1 },
        { type = 'number', label = 'Slots', required = true, min = 1 },
        { type = 'checkbox', label = 'Owned' },
        { type = 'checkbox', label = 'Use Prop' },
        { type = 'select', label = 'Stash Type', options = {
            { value = 'business', label = 'For Business (rental system)' },
            { value = 'job', label = 'For Jobs (job validation)' }
        }, default = 'business'},
    })
    
    if input then
        local i = input
        local pakaiProp = input[6]

        local data = {
            id = i[1]:gsub("%s+", ""),
            label = i[2],
            weight = i[3] * 1000,
            slots = i[4],
            prop = nil,
            coords = nil,
            owned = input[5],
        }

        local optionsData = Citizen.Await(getData(input[7]))
        if not next(optionsData) then return print('Cancelled') end

        lib.table.merge(data, optionsData)

        if data.rentalData and next(data.rentalData) then
            if not data.owned then
                data.owned = true
            end
        end

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
            sp[id] = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z + 1, false, false, false)
            PlaceObjectOnGroundProperly(sp[id])
            SetEntityHeading(sp[id],  data.coords.w)
            FreezeEntityPosition(sp[id], true)

            data.coords = vec(data.coords.xy, data.coords.z + 0.5, data.coords.w)
        end

        RB.t.addTarget(id, {
            loc = data.coords.xyz,
            rad = 1.5,
            opt = {
                {
                    label = data.label,
                    icon  = "fas fa-warehouse",
                    groups = data.groups,
                    func = function ()
                        local myIdentifier = RB.f.getIdentifier()
                        local rentalData = stash[id].rentalData
                        if rentalData then
                            if rentalData.identifier[myIdentifier] then
                                lib.callback('rhd_os:server:checkrentaldate', false, function (Allow)
                                    if Allow then
                                        RB.i.openStash(id)
                                    else
                                        local alert = lib.alertDialog({
                                            header = data.label,
                                            content = 'Waktu sewa kamu sudah habis, apa kamu mau nyewa lagi?',
                                            centered = true,
                                            cancel = true,
                                            labels = {
                                                confirm = "Ya",
                                                cancel = "Tidak"
                                            }
                                        })

                                        if alert == "confirm" then
                                            local input = lib.inputDialog('Penyewaaan Stash', {
                                                { type = 'number', label = 'Mau sewa berapa hari ?', placeholder = '', required = true, min = 1 },
                                            })
                                            
                                            if input then
                                                local cd = {
                                                    id = id,
                                                    day = input[1],
                                                    identifier = myIdentifier,
                                                    price = rentalData.price,
                
                                                }
                                                TriggerServerEvent('rhd_os:server:rentstash', cd)
                                            end
                                        end
                                    end
                                end, rentalData.identifier[myIdentifier])
                            else
                                local input = lib.inputDialog('Penyewaaan Stash', {
                                    { type = 'number', label = 'Mau sewa berapa hari ?', placeholder = '', required = true, min = 1 },
                                })
                                
                                if input then
                                    local cd = {
                                        id = id,
                                        day = input[1],
                                        identifier = myIdentifier,
                                        price = rentalData.price,
    
                                    }
                                    TriggerServerEvent('rhd_os:server:rentstash', cd)
                                end
                            end
                        else
                            RB.i.openStash(id)
                        end
                    end,
                    dist = 1.5
                }
            }
        })
    end
    stash = stashData
end)

RegisterNetEvent('rhd_os:client:syncData', function(data)
    stash = data
end)

CreateThread(function ()
    while not RB.pl do
        Wait(100)
    end
    
    TriggerEvent('rhd_os:client:loadstashdata')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for id, entity in pairs(sp) do
            DeleteEntity(entity)
        end
    end
end)