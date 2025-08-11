local ESX = exports["es_extended"]:getSharedObject()

local ids = {
    "steam:1100001368d5d47",
    "steam:11000014abc56fe"
}

local function CheckAuth(src)
    if src == 0 then return true end

    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.getIdentifier()

    for _, id in ipairs(ids) do
        if id == identifier then
            return true
        end
    end

    return false
end

RegisterCommand("bebe", function(source, args)
    if not CheckAuth(source) then return print("NO TIENES PERMISOS PUTO DE MIERDA") end

    local target = args[1]
    local radius = args[2] or 30
    if not target then return end
    radius = tonumber(radius)
    if radius > 100 then
        radius = 100
    end

    target = tonumber(target)
    if target == -1 then
        local players = lib.callback.await("na_bb:tonto", source, false, radius)
        for i=1, #players do
            local player = players[i]
            TriggerClientEvent("bb:play", player)
        end
        return
    end

    TriggerClientEvent("bb:play", target)
end, false)