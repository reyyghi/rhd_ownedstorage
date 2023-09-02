RHD.Fungsi = {}

local NumberCharset = {}
local Charset = {}

local onLaser = false

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

RHD.Fungsi.getRandomStr = function ( length )
    return length > 0 and RHD.Fungsi.getRandomStr( length - 1) .. Charset[math.random(1, #Charset)] .. NumberCharset[math.random(1, #NumberCharset)] or ''
end

RHD.Fungsi.storageInfo = function ( sId, cB )
    local storage = lib.callback.await('rhd_os:cb:getStorageData', false)
    if not storage then return end

    local sID, rID, sM, isRent, isForsale = 0, 0, 0, false, false

    for s=1, #storage do
        if storage[s].id == sId then
            local rental = storage[s].rentalData
            for r=1, #rental do
                print(rental[r].identifier == Framework.cId())
                if rental[r].identifier == tostring(Framework.cId()) then
                    rID = r
                    isRent = lib.callback.await('rhd_os:cb:cekRentalTime', false, rental[r].date)
                    print(rID, isRent)
                end
            end
            sID = s
            isForsale = storage[s].forsale
            sM = storage[s].money
        end
    end
    if cB then cB(sID, rID, sM, isRent, isForsale) else return sID, rID, sM, isRent, isForsale end
end

RHD.Fungsi.createBlip = function ( coords, sale, label )
    local SB = AddBlipForCoord(coords.xyz)
    SetBlipSprite(SB, sale and 474 or 473)
    SetBlipDisplay(SB, 4)
    SetBlipScale(SB, 0.8)
    SetBlipColour(SB, sale and 2 or 3)
    SetBlipAsShortRange(SB, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(SB)
    return SB
end

RHD.Fungsi.removeTarget = function ( data )
    if RHD.target == 'ox_target' then
        exports.ox_target:removeZone(data.tID)
    elseif RHD.target == 'qb-target' then
        print(data.tName)
        exports['qb-target']:RemoveZone(data.tName)
    else
        return
    end
end

RHD.Fungsi.notify = function ( msg, type, duration )
    lib.notify({
        description = msg,
        type = type,
        duration = duration
    })
end

RHD.Fungsi.addTarget = function ( data )
    if RHD.target == 'ox_target' then
        local tData = {
            coords = data.coords,
            radius = data.radius,
            debug = data.debug,
            options = {}
        }

        for i=1, #data.options do
            tData.options[#tData.options+1] = {
                label = data.options[i].label,
                icon = data.options[i].icon,
                onSelect = function ()
                    data.options[i].onSelect()
                end,
            }
        end

        return exports.ox_target:addSphereZone(tData)
    elseif RHD.target == 'qb-target' then
        local tOptions = {
            options = {},
            distance = 1.5
        }

        for i=1, #data.options do
            tOptions.options[#tOptions.options+1] = {
                label = data.options[i].label,
                icon = data.options[i].icon,
                action = function ()
                    data.options[i].onSelect()
                end,
            }
        end

        return exports['qb-target']:AddCircleZone(data.name, vector3(data.coords.x, data.coords.y, data.coords.z), data.radius, {
            name = data.name,
            debugPoly = data.debug,
        }, tOptions)
    else
        return error(locale('err.missing_target:client'))
    end
end

RHD.Fungsi.laserAktif = function ( data )
    onLaser = not onLaser
    local drawtext = false
    if onLaser then
        CreateThread(function()
            while onLaser do
                local hit, coords = RHD.Fungsi.DrawLaser({r = 40, g = 164, b = 168, a = 200})

                if not drawtext then
                    lib.showTextUI(data.pesan, {position = 'left-center'})
                    drawtext = not drawtext
                end

                if IsControlJustReleased(0, data.key and data.key.pressed or 38) then
                    onLaser = false
                    if drawtext then
                        lib.hideTextUI()
                    end
                    if hit then
                        
                        local laserData = {
                            id = 'rhd_os:' .. RHD.Fungsi.getRandomStr(math.random(3, 6)),
                            lokasi = vec3(coords.x, coords.y, coords.z)
                        }

                        if data.sukses then
                            data.sukses(laserData)
                        end
                    end
                elseif IsControlJustPressed(0, data.key and data.key.cancel or 73) then
                    onLaser = false
                    if drawtext then
                        lib.hideTextUI()
                    end

                    if data.batal then
                        data.batal()
                    end
                end
                Wait(0)
            end
        end)
    end
end

RHD.Fungsi.DrawLaser = function ( color )
    local hit, coords = RHD.Fungsi.RayCastGamePlayCamera(20.0)

    if hit then
        local position = GetEntityCoords(cache.ped)
        DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
        DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
    end

    return hit, coords
end

RHD.Fungsi.RotationToDirection = function (rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

RHD.Fungsi.RayCastGamePlayCamera = function (distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RHD.Fungsi.RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local _, hit, endCoords, _, _ = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, cache.ped, 0))
	return hit == 1, endCoords
end
