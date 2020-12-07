ESX = nil
local players = {}
local maxPlayers = GetConvarInt('sv_maxclients', 32)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("scoreboard:getPlayers", function(source, cb) 
    cb(players, maxPlayers)
end)


RegisterServerEvent("scoreboard:getPlayerPing")
AddEventHandler("scoreboard:getPlayerPing", function()
    local _source = source
    TriggerClientEvent("scoreboard:playerPing", _source, GetPlayerPing(_source))
end)

AddEventHandler("esx:setJob", function(playerId, job, lastJob) 
    players[playerId].job = job.name
    TriggerClientEvent("scoreboard:updatePlayers", -1, players)
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer) 
    local id = xPlayer.source
    players[id] = {}
    players[id].ping = GetPlayerPing(id)
    players[id].playerId = id
    players[id].name = xPlayer.getName()
    players[id].job = xPlayer.job.name
    TriggerClientEvent("scoreboard:updatePlayers", -1, players)
end)

AddEventHandler("onResourceStart", function(resource) 
    if GetCurrentResourceName() ~= resource then return end
    Citizen.Wait(1000)
    local totalPlayers = ESX.GetPlayers()
    for i = 1, #totalPlayers do
        local xPlayer = ESX.GetPlayerFromId(totalPlayers[i])
        local id = xPlayer.source
        players[id] = {}
        players[id].ping = GetPlayerPing(id)
        players[id].playerId = id
        players[id].name = xPlayer.getName()
        players[id].job = xPlayer.job.name
    end
    TriggerClientEvent("scoreboard:updatePlayers", -1, players)
end)

function ping()
    for k,v in pairs(players) do
        local ping = GetPlayerPing(k)

        if ping then
            if ping > 0 then
                v.ping = ping
            end
        else
            v.ping = '-1'
        end
    end
    TriggerClientEvent('scoreboard:ping', -1, players)
end