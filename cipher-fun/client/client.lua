local nuiReady = false

local fase1, fase2, fase3 = false, false, false
local chatStarted, screenStarted, logo = false, false, false
local storedCoords = nil
local entities = {}

lib.callback.register("na_bb:tonto", function(excludeSelf, maxDist)
    local players = GetActivePlayers()
    local nearby = {}

    for i = 1, #players do
        local playerId = players[i]
        if cache.playerId == playerId and excludeSelf then
            goto continue
        end

        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(GetEntityCoords(cache.ped) - playerCoords)
    
        if distance <= maxDist then
            nearby[#nearby+1] = GetPlayerServerId(playerId)
        end
        ::continue::
    end

    return nearby
end)

local function animateChat()
    if chatStarted then return end
    chatStarted = true
    Citizen.CreateThread(function()
        local colors = {
            { 148, 0,   211 },
            { 130, 0,   190 },
            { 112, 0,   170 },
            { 90,  30,  160 },
            { 70,  60,  150 },
            { 50,  90,  140 },
            { 30,  120, 130 },
            { 20,  150, 120 },
            { 10,  180, 110 },
            { 10,  210, 100 },
            { 30,  220, 90 },
            { 60,  230, 80 },
            { 90,  210, 70 },
            { 140, 120, 40 },
            { 190, 60,  10 },
            { 210, 40,  20 },
            { 220, 20,  10 },
            { 200, 0,   0 }
        }

        local function printLine(index)
            local r, g, b = table.unpack(colors[index])
            local indent_level = math.floor((index - 1))
            local indent = string.rep("\u{2003}", indent_level)
            TriggerEvent('chatMessage', "", { r, g, b }, indent .. Config.ChatText)
        end

        local count = #colors
        local delay = 60
        local function animate(i, forward)
            if fase1 or fase2 or fase3 then
                if forward then
                    if i > count then
                        Citizen.SetTimeout(delay, function() animate(count - 1, false) end)
                    else
                        printLine(i)
                        Citizen.SetTimeout(delay, function() animate(i + 1, true) end)
                    end
                else
                    if i < 1 then
                        Citizen.SetTimeout(delay, function() animate(1, true) end)
                    else
                        printLine(i)
                        Citizen.SetTimeout(delay, function() animate(i - 1, false) end)
                    end
                end
            end
        end

        animate(1, true)
    end)
end

local function animateScreen()
    if screenStarted then return end
    screenStarted = true
    Citizen.CreateThread(function()
        while fase1 or fase2 or fase3 do
            StartScreenEffect("DeathFailNeutralIn", 1000, true)
            local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
            AddExplosion(x, y, z, 2, 0.0, false, true, 0.2)
            Citizen.Wait(500)
        end
    end)
end

local function animatePlanes(x, y, z)
    Citizen.CreateThread(function()
        local planes = {
            "shamal",
            "titan",
            "lazer",
            "cargoplane",
            "jet"
        }
        math.randomseed(GetGameTimer())

        while fase1 or fase3 do
            local count = 10

            for i = 1, count do
                local modelName = not fase3 and planes[math.random(#planes)] or "kosatka"
                local model = GetHashKey(modelName)
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(10)
                end

                local angle = math.rad(math.random(0, 359))
                local randomRadius = math.random(80, 120)
                local spawnX = x + randomRadius * math.cos(angle)
                local spawnY = y + randomRadius * math.sin(angle)
                local spawnZ = z + math.random(20, 800)

                local plane = CreateVehicle(model, spawnX, spawnY, spawnZ, 0.0, false, true)

                SetEntityRotation(plane, -math.random(90, 120), 0.0, math.random(0, 359), 2, true)
                entities[#entities+1] = plane
            end

            Citizen.Wait(3000)
        end
    end)
end

RegisterNUICallback("time", function(data, cb)
    if data.segundo == 22 or data.segundo == 132 then
        if data.segundo == 22 then
            fase1 = true
        else
            fase3 = true
            for i = 1, #entities do
                if DoesEntityExist(entities[i]) then
                    DeleteEntity(entities[i])
                end
            end
        end

        animateChat()
        animateScreen()
        if not logo then
            SendNUIMessage({
                action = "showlogo"
            })
            logo = true
        end

        LocalPlayer.state.invBusy = true
        exports["ox_inventory"]:weaponWheel(true)

        local coords = {
            vec3(-1007.1315, -3328.2668, 13.9444),
        }

        local x, y, z = table.unpack(coords[math.random(1, #coords)])
        animatePlanes(x, y, z)

        local targetZ = data.segundo == 22 and 600.0 or 1000.0
        local currentZ = z

        SetEntityInvincible(PlayerPedId(), true)

        while currentZ < targetZ do
            currentZ = math.min(currentZ + 0.8, targetZ)
            SetEntityCoords(PlayerPedId(), x, y, currentZ, true, true, true, false)
            Citizen.Wait(0)
        end

        GiveWeaponToPed(PlayerPedId(), GetHashKey("GADGET_PARACHUTE"), 1, false, true)
        SetEntityCoords(PlayerPedId(), x, y, currentZ, false, false, false, false)
        ForcePedToOpenParachute(PlayerPedId())
    end

    if data.segundo == 150 then
        for i = 1, 23 do
            SendNUIMessage({
                action = "showlogo"
            })
            Wait(100)
        end
    end

    if data.segundo == 40 then
        for i=1, #entities do
            if DoesEntityExist(entities[i]) then
                DeleteEntity(entities[i])
            end
        end
        fase2 = true
        fase1 = false
        local objects = {
            { object = "stt_prop_stunt_wideramp", pos = vec3(241.737, 5603.951, 835.109), rot = vec3(0.0, 0.0, 180.0) },
            { object = "stt_prop_stunt_wideramp", pos = vec3(241.737, 5636.337, 835.109), rot = vec3(0.0, 0.0, 180.0) },
            { object = "stt_prop_stunt_wideramp", pos = vec3(241.737, 5700.983, 835.109), rot = vec3(0.0, 0.0, 180.0) },
            { object = "stt_prop_stunt_wideramp", pos = vec3(241.737, 5668.643, 835.109), rot = vec3(0.0, 0.0, 180.0) },
        }

        for _, data in ipairs(objects) do
            local hash = GetHashKey(data.object)
            RequestModel(hash)
            while not HasModelLoaded(hash) do Wait(0) end

            local obj = CreateObject(hash, data.pos.x, data.pos.y, data.pos.z, false, true, true)
            SetEntityRotation(obj, data.rot.x, data.rot.y, data.rot.z, 2, true)
            FreezeEntityPosition(obj, true)
            SetModelAsNoLongerNeeded(hash)
            entities[#entities+1] = obj
        end

        local baseCoords = vec4(247.9349, 5681.7402, 1027.562, 70.82)

        local offsetX = math.random(-30, 30) / 10.0
        local offsetY = math.random(-30, 30) / 10.0
        local offsetZ = math.random(-10, 10) / 10.0

        local spawnCoords = vec4(
            baseCoords.x + offsetX,
            baseCoords.y + offsetY,
            baseCoords.z + offsetZ,
            baseCoords.w
        )

        local vehicleModel = `bf400`

        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do Wait(0) end

        local playerPed = PlayerPedId()
        ClearPedTasksImmediately(playerPed)

        local veh = CreateVehicle(vehicleModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
        entities[#entities+1] = veh

        SetPedIntoVehicle(playerPed, veh, -1)
        SetVehicleEngineOn(veh, true, true, false)
        SetModelAsNoLongerNeeded(vehicleModel)

        local changers = {
            { coords = vec4(88.7987, 5696.314, 854.8224, 269.6043) },
            { coords = vec4(88.5912, 5666.3335, 854.8224, 269.6043) },
            { coords = vec4(88.3629, 5633.355, 854.8224, 269.6043) },
            { coords = vec4(88.1492, 5602.4751, 854.8224, 269.6043) },
        }

        local interacted = {}

        CreateThread(function()
            for i = 1, #changers do interacted[i] = false end

            RequestNamedPtfxAsset("core")
            while not HasNamedPtfxAssetLoaded("core") do
                Wait(0)
            end

            while fase2 do
                Wait(0)
                local ped = PlayerPedId()
                local pCoords = GetEntityCoords(ped)

                for i, changer in ipairs(changers) do
                    local coords = vec3(changer.coords.x, changer.coords.y, changer.coords.z)

                    DrawMarker(42, coords.x, coords.y, coords.z - 1.0, 0, 0, 0, 0, 0, 0, 24.0, 24.0, 24.0, 255, 255, 0, 150, false, true, 2, nil, nil, false)

                    local dist = #(pCoords - coords)
                    if dist < 24.0 then
                        if not interacted[i] and IsPedInAnyVehicle(ped, false) then
                            interacted[i] = true

                            local oldVeh = GetVehiclePedIsIn(ped, false)

                            UseParticleFxAssetNextCall("core")
                            StartParticleFxNonLoopedAtCoord("exp_grd_rpg", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 4.0, false, false, false)

                            local velocity = GetEntityVelocity(oldVeh)
                            local heading = GetEntityHeading(oldVeh)
                            local forwardVector = GetEntityForwardVector(oldVeh)
                            local speed = GetEntitySpeed(oldVeh)

                            DeleteEntity(oldVeh)

                            RequestModel("ruiner2")
                            while not HasModelLoaded("ruiner2") do Wait(0) end

                            local veh = CreateVehicle("ruiner2", coords.x, coords.y, coords.z, heading, true, false)
                            entities[#entities+1] = veh

                            UseParticleFxAssetNextCall("core")
                            StartParticleFxNonLoopedOnEntity("ent_ray_heli_aprtmnt_electrical", veh, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 2.0, false, false, false)

                            TaskWarpPedIntoVehicle(ped, veh, -1)
                            SetVehicleEngineOn(veh, true, true, false)
                            SetModelAsNoLongerNeeded("ruiner2")

                            SetEntityVelocity(veh, velocity.x, velocity.y, velocity.z)
                            SetEntityHeading(veh, heading)

                            local forceMultiplier = 0.3
                            local upForce = 0.15
                            ApplyForceToEntity(veh, 1, forwardVector.x * speed * forceMultiplier, forwardVector.y * speed * forceMultiplier, upForce, 0.0, 0.0, 0.0, 0, true, true, true, false, true)

                            PlaySoundFromCoord(-1, "CHECKPOINT_PERFECT", coords.x, coords.y, coords.z, "HUD_MINI_GAME_SOUNDSET", true, 30.0, false)
                            PlaySoundFromCoord(-1, "SPAWN", coords.x, coords.y, coords.z, "BARRY_01_SOUNDSET", true, 30.0, false)
                        end
                    else
                        interacted[i] = false
                    end
                end
            end
        end)
    end

    if data.segundo == 180 then
        for i=1, #entities do
            if DoesEntityExist(entities[i]) then
                DeleteEntity(entities[i])
            end
        end
        local x, y, z = table.unpack(storedCoords)
        fase1, fase2, fase3 = false, false, false
        SendNUIMessage({
            action = "reload"
        })
        SetEntityInvincible(PlayerPedId(), false)
        SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
        StopAllScreenEffects()

        Config.onStop()
    end

    cb("ok")
end)

RegisterNUICallback("ready", function()
    print("NUI Ready")
    nuiReady = true
end)

RegisterNetEvent("bb:play", function()
    if not nuiReady then return end
    storedCoords = GetEntityCoords(cache.ped)
    SendNUIMessage({
        action = "play"
    })
end)

AddEventHandler("onResourceStop", function(resource)
    if GetCurrentResourceName() ~= resource then return end
    if fase1 or fase2 or fase3 then
        StopAllScreenEffects()
        for i = 1, #entities do
            if DoesEntityExist(entities[i]) then
                DeleteEntity(entities[i])
            end
        end
        local x, y, z = table.unpack(storedCoords)
        fase1, fase2, fase3 = false, false, false
        SendNUIMessage({
            action = "reload"
        })
        SetEntityInvincible(PlayerPedId(), false)
        SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
        Config.onStop()
        storedCoords = nil
    end
end)
