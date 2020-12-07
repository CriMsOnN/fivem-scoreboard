ESX = nil
local scoreboard = false
local playerPing = 0
local maxPlayers = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(2000)
    ESX.TriggerServerCallback('scoreboard:getPlayers', function(players, totalPlayers)
        maxPlayers = totalPlayers
        updatePlayers(players)
	end)
end)

RegisterNetEvent("scoreboard:updatePlayers")
AddEventHandler("scoreboard:updatePlayers", function(players) 
    updatePlayers(players)
end)

RegisterNetEvent("scoreboard:ping")
AddEventHandler("scoreboard:ping", function(players) 
    SendNUIMessage({
        action = "ping",
        players = players
    })
end)

RegisterNetEvent("scoreboard:playerPing")
AddEventHandler("scoreboard:playerPing", function(ping) 
    playerPing = ping
    print(ping)
end)

updatePlayers = function(players)
    local playerlist = {}
    local jobs = {
        EMS = 0, 
        LSPD = 0, 
        MECHANIC = 0,
    }
    local connectedPlayers = #players

    for k,v in pairs(players) do
        connectedPlayers = connectedPlayers + 1
        if v.job == "police" then
            jobs.LSPD = job.LSPD + 1
        elseif v.job == "ambulance" then
            jobs.EMS = job.EMS + 1
        elseif v.job == "mechanic" then
            jobs.MECHANIC = job.MECHANIC + 1
        end
    end

    SendNUIMessage({
        action = "update",
        playerName = GetPlayerName(PlayerId()),
        playerID = GetPlayerServerId(PlayerId()),
        playerPing = playerPing,
        connected = connectedPlayers - 1,
        maxPlayers = maxPlayers
    })

    SendNUIMessage({
        action = "updateJobs",
        jobs = jobs,
        connected = connectedPlayers,
    })
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

        if IsControlJustReleased(0, Config.Key) and IsInputDisabled(0) then
            scoreboard = not scoreboard
            if scoreboard then
                SendNUIMessage({action = 'enable'})
                TriggerServerEvent("scoreboard:getPlayerPing")
            else
                SendNUIMessage({action = 'close'})
            end
			Citizen.Wait(1000)
		end
	end
end)

RegisterNUICallback("close", function() 
    scoreboard = false
    SetNuiFocus(false, false)
end)


AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        
	end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.Wait(5000)
        ESX.TriggerServerCallback('scoreboard:getPlayers', function(players, maxPlayers)
            maxPlayers = maxPlayers
	    end)
    end
end)

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end