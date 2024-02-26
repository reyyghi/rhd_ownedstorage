Placer = {}
Laser = {}

local ActiveLaser = false
local PlacingObject = false
local CurrentObject = nil

local propData = require 'data.prop'

local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function RayCastGamePlayCamera(distance)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * distance)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end

local function CancelPlacement()
    DeleteObject(CurrentObject)
    PlacingObject = false
    CurrentObject = nil
end

function Laser.start()
    ActiveLaser = true

    local text = [[
    [X]: Cancel
    [Enter]: Confirm
    ]]
    lib.showTextUI(text)

    local results = promise.new()
    CreateThread(function()
        while true do
            local wait = 1
            if ActiveLaser then
                local color = {r = 255, g = 255, b = 255, a = 200}
                local position = GetEntityCoords(PlayerPedId())
                local hit, coords, entity = RayCastGamePlayCamera(1000.0)

                DisableControlAction(0, 73, true)
                DisableControlAction(0, 176, true)

                if hit then
                    DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
                end

                if IsDisabledControlJustPressed(0, 73) then
                    results:resolve(false)
                    lib.hideTextUI()
                    ActiveLaser = false
                end
    
                if IsDisabledControlJustPressed(0, 176) then

                    local sendData = {
                        coords = vec(coords.x, coords.y, coords.z),
                    }
                    
                    lib.setClipboard(table.concat( sendData, ", "))
                    results:resolve(sendData)
                    lib.hideTextUI()
                    ActiveLaser = false
                end
            end
            Wait(wait)
        end
    end)
    return Citizen.Await(results)
end

local function reqModel(model, timeout)
    model = type(model) == 'string' and joaat(model) or model
    RequestModel(model)
    if not HasModelLoaded(model) then
        while not HasModelLoaded(model) do
            RequestModel(model)
            Wait(10)
        end
    end
end

function Placer.start()
    if PlacingObject then return end

    local propIndex = 1
    local object = propData[propIndex]

    local text = [[
    [X]: Cancel
    [Enter]: Confirm
    [Arrow Up/Down]: Height
    [Arrow Right/Left]: Rotate Prop
    [Mouse Scroll Up/Down]: Change Prop
    ]]

    lib.showTextUI(text)
    reqModel(object, 1500)
    CurrentModel = object
    CurrentObject = CreateObject(object, 1.0, 1.0, 1.0, false, false, false)

    SetEntityHeading(CurrentObject, 0)
    SetEntityCollision(CurrentObject, false, false)
    FreezeEntityPosition(CurrentObject, true)

    local heading = 0.0
    local prefixZ = 0.0

    local results = promise.new()
    CreateThread(function()
        PlacingObject = true

        while PlacingObject do
            local hit, coords, entity = RayCastGamePlayCamera(20.0)
            CurrentCoords = GetEntityCoords(CurrentObject)

            if hit == 1 then
                SetEntityCoords(CurrentObject, coords.x, coords.y, coords.z + prefixZ)
            end

            DisableControlAction(0, 174, true)
            DisableControlAction(0, 175, true)
            DisableControlAction(0, 73, true)
            DisableControlAction(0, 176, true)
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)
            DisableControlAction(0, 172, true)
            DisableControlAction(0, 173, true)
            
            if IsDisabledControlPressed(0, 174) then
                heading = heading + 0.5
                if heading > 360 then heading = 0.0 end
            end
    
            if IsDisabledControlPressed(0, 175) then
                heading = heading - 0.5
                if heading < 0 then heading = 360.0 end
            end

            if IsDisabledControlJustPressed(0, 172) then
                prefixZ += 0.1
            end
    
            if IsDisabledControlJustPressed(0, 173) then
                prefixZ -= 0.1
            end

            if IsDisabledControlJustPressed(0, 14) then
                local newIndex = propIndex+1
                local newModel = propData[newIndex]
                if newModel then
                    DeleteEntity(CurrentObject)
                    reqModel(newModel)
                    local prop = CreateObject(newModel, 1.0, 1.0, 1.0, false, false, false)
                    SetEntityCollision(prop, false, false)
                    FreezeEntityPosition(prop, true)
                    CurrentObject = prop
                    propIndex = newIndex
                    object = newModel
                end
            end

            if IsDisabledControlJustPressed(0, 15) then
                local newIndex = propIndex-1

                if newIndex >= 1 then
                    local newModel = propData[newIndex]
                    if newModel then
                        DeleteEntity(CurrentObject)
                        reqModel(newModel)
                        local prop = CreateObject(newModel, 1.0, 1.0, 1.0, false, false, false)
                        SetEntityCollision(prop, false, false)
                        FreezeEntityPosition(prop, true)
                        CurrentObject = prop
                        propIndex = newIndex
                        object = newModel
                    end
                end
            end
            
            if IsDisabledControlJustPressed(0, 73) then
                results:resolve(false)
                CancelPlacement()
            end

            SetEntityHeading(CurrentObject, heading)

            if IsDisabledControlJustPressed(0, 176) then
                
                if hit == 1 then
                    local sendData = {
                        coords = vec4(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, heading),
                        model = object
                    }
                    
                    lib.setClipboard(table.concat( sendData, ", "))
                    results:resolve(sendData)
                end

                CancelPlacement()
            end
            
            Wait(1)
        end

        lib.hideTextUI()
    end)

    return Citizen.Await(results)
end