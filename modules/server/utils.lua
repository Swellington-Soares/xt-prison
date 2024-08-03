local config            = require 'configs.server'
local prisonBreakcfg    = require 'configs.prisonbreak'

local utils = {}

-- Check if Player is a Lifer --
function utils.liferCheck(source)
    local playerState = Player(source)?.state
    local citizenid = getCharID(source)
    local jailTime = playerState.jailTime
    local callback = false
    for x = 1, #config.Lifers do
        if config.Lifers[x] == citizenid then
            if jailTime ~= 999 then
                setJailTime(source, 999)
            end
            callback = true
            break
        end
    end
    return callback
end exports('isLifer', utils.liferCheck)

-- Check if Player is Cop --
function utils.isCop(source)
    local callback = false
    local type = type(config.PoliceJobs)
    if type == 'string' then
        return charHasJob(config.PoliceJobs)
    elseif type == 'table' then
        for x = 1, #config.PoliceJobs do
            if charHasJob(config.PoliceJobs[x]) then
                callback = true
                break
            end
        end
    end
    return callback
end

-- Distance Between 2 Players --
function utils.playerDistanceCheck(player1, player2)
    if player1 == player2 then return true end

    local playerPed = GetPlayerPed(player1)
    local targetPed = GetPlayerPed(player2)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    local dist = #(targetCoords - playerCoords)

    return (dist < 5)
end

-- Distance Between Player and Terminal --
function utils.terminalDistanceCheck(player1, terminal)
    local playerPed = GetPlayerPed(player1)
    local playerCoords = GetEntityCoords(playerPed)
    local hackCoords = prisonBreakcfg.HackZones[terminal].coords
    local dist = #(hackCoords - playerCoords)

    return (dist < 3)
end

function utils.checkJailTime(source)
    local playerState = Player(source)?.state
    local isLifer = utils.liferCheck(source)
    local jailTime

    if isLifer then
        lib.notify(source, {
            title = 'You\'re in jail for life!',
            icon = 'fas fa-lock',
            type = 'info'
        })
        return 999
    else
        jailTime = playerState.jailTime
        if jailTime > 0 then
            lib.notify(source, {
                title = 'Jail Time',
                description = ('You have %s months left.'):format(jailTime),
                icon = 'fas fa-hourglass',
                type = 'info'
            })
        elseif jailTime <= 0 then
            lib.notify(source, {
                title = 'Jail Time',
                description = 'You don\'t have any jail time left!',
                icon = 'fas fa-hourglass-end',
                type = 'info'
            })
        end
    end

    return jailTime
end

return utils