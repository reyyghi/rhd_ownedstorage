local currentData = {}
local Target = {}
local SB = {}

RHD.default = {
    slots = 50,
    weight = 100,
    salePrice = 10000000
}

local registerNewStorage = function ( storageData )
    local input = lib.inputDialog(locale('admin_input:label'), {
        { type = 'input', label = locale('input.new_storage:label'), placeholder = locale('admin_input:label'), required = true },
        { type = 'number', label = locale('input.new_storage:slots'), default = RHD.default['slots'], min = 1, max = 200 },
        { type = 'number', label = locale('input.new_storage:weight'), default = RHD.default['weight'], min = 10, max = 200 },
        { type = 'number', label = locale('input.new_storage:rent_price'), default = 1000 },
        { type = 'checkbox', label = locale('input.new_storage:forsale_label') },
    })
    
    if input then
        
        local newData = {
            id = storageData.id,
            label = tostring(input[1]),
            weight = tonumber(input[3]) * 1000,
            slots = tonumber(input[2]),
            lokasi = storageData.lokasi,
            rentalData = {},
            rentalPrice = tonumber(input[4]),
            forsale = input[5],
            salePrice = RHD.default['salePrice'],
            money = 0,
            owner = nil
        }

        if input[5] then
            local price_input = lib.inputDialog(newData.label, {
                { type = 'number', label = locale('input.new_storage:sale_price'), default = RHD.default['salePrice'], required = true },
            })
            
            if price_input then

                newData.salePrice = tonumber(price_input[1])
                TriggerServerEvent('rhd_os:registerNewStorage', newData)

                return
            end

            return
        end

        TriggerServerEvent('rhd_os:registerNewStorage', newData)
    end
end

local cerateNew = function ()
    RHD.Fungsi.laserAktif({
        key = {
            pressed = 38,
            cancel = 73
        },
        pesan = string.format('%s  \n%s', locale('drawtext_label:lasers:confirm'), locale('drawtext_label:lasers:cancel')),
        sukses = function ( data )
            registerNewStorage({ id = data.id, lokasi = data.lokasi })
        end,
        batal = function ()
            print('cancel')
        end
    })
end

RegisterNetEvent('rhd_os:createnNew', cerateNew)

RegisterNetEvent('rhd_os:removeCurrentTarget', function( tId )
    exports.ox_target:removeZone(Target[tId])
    RemoveBlip(SB[tId])
end)

RegisterNetEvent('rhd_os:rhd_os:loadTarget', function( storageData )

    storageData = storageData or currentData

    currentData = storageData
    
    if SB[storageData.id] then RemoveBlip(SB[storageData.id]) end
    if Target[storageData.id] then exports.ox_target:removeZone(Target[storageData.id]) end

    local targetData = {
        coords = storageData.lokasi,
        radius = 0.5,
        debug = false,
        options = {}
    }

    local sId, rId, sM, isRent, isForsale = RHD.Fungsi.storageInfo( storageData.id )

    if storageData.owner ~= LocalPlayer.state.identifier then
        if isRent then
            targetData.options[#targetData.options+1] = {
                label = locale('target.storage:label_open'),
                icon = 'fas fa-warehouse',
                onSelect = function ()
                    exports.ox_inventory:openInventory('stash', storageData.id)
                end,
                distance = 1.5
            }
        elseif LocalPlayer.state.group ~= 'admin' then
            targetData.options[#targetData.options+1] = {
                label = locale('target.storage:label_rental'),
                icon = 'fas fa-warehouse',
                onSelect = function ()
                    local rentPrice = tonumber(storageData.rentalPrice)

                    local input = lib.inputDialog(locale('admin_input:label'), {
                        { type = 'number', label = locale('input.rent_storage:label'), placeholder = '1 Hari', default = 1 },
                    })
                    
                    if input then

                        rentPrice *= tonumber(input[1])

                        local alert = lib.alertDialog({
                            header = locale('alert.rent_storage:header', LocalPlayer.state.name),
                            content = locale('alert.rent_storage:content', lib.math.groupdigits(rentPrice)),
                            centered = true,
                            cancel = true,
                            labels = {
                                confirm = locale('alert.rent_storage:confirm'),
                                cancel = locale('alert.rent_storage:cancel')
                            }
                        })

                        if alert == 'confirm' then
                            if not RHD.Fungsi.moneyCheck( rentPrice ) then 
                                return TriggerEvent('mn:shownotif', locale('notify.storage:player_not_enough_money', lib.math.groupdigits(rentPrice)), 'error')
                            end
        
                            TriggerServerEvent('rhd_os:rentStorage', sId, rId, storageData)
                        end
                    end

                end,
                distance = 1.5
            }
        end
    end
    
    if storageData.owner == LocalPlayer.state.identifier or LocalPlayer.state.group == 'admin' then
        targetData.options[#targetData.options+1] = {
            label = locale('target.storage:label_manage'),
            icon = 'fas fa-warehouse',
            onSelect = function ()

                lib.registerContext({
                    id = 'rhd_os:manage_menu',
                    title = storageData.label,
                    options = {
                        {
                            title = locale('context.storage:label.open_storage'),
                            icon = 'warehouse',
                            onSelect = function ()
                                exports.ox_inventory:openInventory('stash', storageData.id)
                            end
                        },
                        {
                            title = locale('context.storage:label.manage_money'),
                            icon = 'hand-holding-dollar',
                            onSelect = function ()

                                local _, _, Money, _, _ = RHD.Fungsi.storageInfo( storageData.id )

                                lib.registerContext({
                                    id = 'manage_money',
                                    title = locale('context.storage:manage_money.info', lib.math.groupdigits(tonumber(Money), '.')),
                                    menu = 'rhd_os:manage_menu',
                                    onBack = function ()
                                        
                                    end,
                                    options = {
                                        {
                                            title = locale('context.storage:manage_money.withdraw'),
                                            description = '',
                                            icon = 'hand-holding-dollar',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'input', label = locale('input.manage_storage.withdraw_money:label'), default = 1 },
                                                })
                                                
                                                if input then
                                                    if Money < tonumber(input[1]) then
                                                        return TriggerEvent('mn:shownotif', locale('notify.storage:storage_not_enough_money'), 'error')
                                                    end
                                                    TriggerServerEvent('rhd_os:withdraw', sId, tonumber(input[1]))
                                                end
                                            end,
                                        },
                                    },
                                })
                                lib.showContext('manage_money')
                            end
                        },
                        {
                            title = locale('context.storage:label.storage_setting'),
                            icon = 'gear',
                            onSelect = function ()
                                lib.registerContext({
                                    id = 'storage_setting',
                                    title = locale('context.storage:label.storage_setting'),
                                    menu = 'rhd_os:manage_menu',
                                    onBack = function ()
                                        
                                    end,
                                    options = {
                                        {
                                            title = locale('context.storage:storage_setting.slots'),
                                            description = '',
                                            icon = 'gear',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'number', label = locale('input.setting_storage.slots:label'), default = 1, min = 1, max = 200 },
                                                })
                                                
                                                if input then
                                                    storageData.slots = tonumber(input[1])
                                                    TriggerServerEvent('rhd_os:setstorage', sId, storageData)
                                                end
                                                
                                            end,
                                        },
                                        {
                                            title = locale('context.storage:storage_setting.weight'),
                                            description = '',
                                            icon = 'gear',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'number', label = locale('input.setting_storage.weight:label'), default = 10, min = 10, max = 200 },
                                                })
                                                
                                                if input then
                                                    storageData.weight = tonumber(input[1]) * 1000
                                                    TriggerServerEvent('rhd_os:setstorage', sId, storageData)
                                                end
                                            end,
                                        },
                                        {
                                            title = locale('context.storage:storage_setting.label'),
                                            description = '',
                                            icon = 'gear',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'input', label = locale('input.setting_storage.label:label'), placeholder = locale('admin_input:label') },
                                                })
                                                
                                                if input then
                                                    storageData.label = tostring(input[1])
                                                    TriggerServerEvent('rhd_os:setstorage', sId, storageData, true)
                                                end
                                            end,
                                        },
                                        {
                                            title = locale('context.storage:storage_setting.rent_price'),
                                            description = '',
                                            icon = 'gear',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'number', label = locale('input.setting_storage.rent_price:label'), description = locale('input.setting_storage.rent_price:desc'), default = 100, min = 1, max = 10000 },
                                                })
                                                
                                                if input then
                                                    storageData.rentalPrice = tonumber(input[1])
                                                    TriggerServerEvent('rhd_os:setstorage', sId, storageData)
                                                end
                                            end,
                                        },
                                        {
                                            title = locale('context.storage:storage_setting.sale'),
                                            description = '',
                                            icon = 'dollar',
                                            onSelect = function(args)
                                                local input = lib.inputDialog(locale('admin_input:label'), {
                                                    { type = 'number', label = locale('input.setting_storage.sale_price:label'), required = true },
                                                })
                                                
                                                if input then
                                                    storageData.salePrice = tonumber(input[1])
                                                    storageData.forsale = true
                                                    storageData.owner = LocalPlayer.state.identifier
                                                    TriggerServerEvent('rhd_os:setstorage', sId, storageData, true)
                                                end
                                            end,
                                        },
                                    },
                                })
                                lib.showContext('storage_setting')
                            end
                        },
                    },
                })

                lib.showContext('rhd_os:manage_menu')
            end,
            distance = 1.5
        }
    end

    if isForsale and LocalPlayer.state.group ~= 'admin' then
        targetData.options[#targetData.options+1] = {
            label = locale('target.storage:label_buy'),
            icon = 'fas fa-warehouse',
            onSelect = function ()
                local storagePrice = tonumber(storageData.salePrice)

                if not RHD.Fungsi.moneyCheck( storagePrice ) then 
                    return TriggerEvent('mn:shownotif', locale('notify.storage:player_not_enough_money', lib.math.groupdigits(storagePrice)), 'error')
                end

                LocalPlayer.state.invBusy = true
                local alert = lib.alertDialog({
                    header = locale('alert.buy_storage:header', LocalPlayer.state.name),
                    content = locale('alert.buy_storage:content', lib.math.groupdigits(storagePrice)),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = locale('alert.buy_storage:confirm'),
                        cancel = locale('alert.buy_storage:cancel')
                    }
                })

                if alert == 'confirm' then
                    TriggerServerEvent('rhd_os:buyStorage', sId, storageData)
                end
                LocalPlayer.state.invBusy = false
            end,
            distance = 1.5
        }
    end

    if LocalPlayer.state.group == 'admin' then
        targetData.options[#targetData.options+1] = {
            label = locale('admin_target.storage:label_delete'),
            icon = 'fas fa-trash',
            onSelect = function ()
                TriggerServerEvent('rhd_os:removeCurrentStorage', sId, storageData.id)
            end,
            distance = 1.5
        }
    end

    SB[storageData.id] = RHD.Fungsi.createBlip( vec3(storageData.lokasi.x, storageData.lokasi.y, storageData.lokasi.z), storageData.forsale, storageData.label )
    Target[storageData.id] = exports.ox_target:addSphereZone(targetData)
end)
