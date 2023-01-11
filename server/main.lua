local cache = {}
local days = {
    ['mon'] = 2,
    ['tue'] = 3,
    ['wed'] = 4,
    ['thu'] = 5,
    ['fri'] = 6,
    ['sat'] = 7,
    ['sun'] = 1
}

if Config.oldESX then
    --esx initiation
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

--get mission
ESX.RegisterServerCallback('0mission0:getMission', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(cache[xPlayer.identifier])
end)

--determine progress
RegisterServerEvent('0mission0:getPointforMission')
AddEventHandler('0mission0:getPointforMission', function(mis, qnty, xPlayer)
    if not xPlayer then
        xPlayer = ESX.GetPlayerFromId(source)
    end
    local inCache = cache[xPlayer.identifier][tostring(mis)]
    local newQunty
    if inCache then
        if inCache.finish == 0 then
            newQunty = inCache.progress + qnty
            if newQunty >= inCache.max then
                newQunty = inCache.max
                inCache.finish = 1
                xPlayer.showNotification(Config.finish)
                MySQL.update('UPDATE mission SET finish = ?, progress = ? WHERE identifier = ? AND mission_id = ?', {
                    1, 
                    cache[xPlayer.identifier][tostring(mis)].progress, 
                    xPlayer.identifier, 
                    mis})
            end
            inCache.progress = newQunty
            TriggerClientEvent('0mission0:updateNUI', xPlayer.source, mis, (newQunty / inCache.max), math.floor(newQunty) ..'/'.. inCache.max)
        end
    end
end)

--give reward
RegisterServerEvent('0mission0:reward')
AddEventHandler('0mission0:reward', function(mid)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update('UPDATE mission SET finish = ?, progress = ? WHERE identifier = ? AND mission_id = ?', {2, cache[xPlayer.identifier][tostring(mid)].progress, xPlayer.identifier, mid})
    cache[xPlayer.identifier][tostring(mid)].finish = 2
    giveReward(mid, source, xPlayer)
end)

--give mission
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    cache[xPlayer.identifier] = {}
    local result = MySQL.query.await('SELECT * FROM mission WHERE identifier = ?', {xPlayer.identifier})
    if #result < Config.missionNo then
        local t = {}
        math.randomseed(os.time())
        local found = false
        for i=1, (Config.missionNo- #result) do
            repeat
            found = false
            n = math.random(1, #mission)
            for a=1, i do
                if t[a] == n then
                    found = true
                end
            end
            Citizen.Wait(0)
            until (found == false)
            MySQL.insert('INSERT INTO `mission` (`mission_id`, `max`, `identifier`) VALUES(?, ?, ?)', {n, mission[n].max, xPlayer.identifier})
            t[i] = n
            local data = {progress = 0, max = mission[n].max, finish = 0}
            cache[xPlayer.identifier][tostring(n)] = data
        end
        if #result < 0 then
            for i=1, #result do
                local n = result[i].mission_id
                local data = {progress = result[i].progress, max = result[i].max, finish = result[i].finish}
                cache[xPlayer.identifier][tostring(n)] = data
            end
        end
    else
        for i=1, Config.missionNo do
            local n = result[i].mission_id
            local data = {progress = result[i].progress, max = result[i].max, finish = result[i].finish}
            cache[xPlayer.identifier][tostring(n)] = data
        end
    end
end)

--save to database
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        for id, mis in pairs(cache) do
            for mid, data in pairs(mis) do 
                MySQL.update('UPDATE mission SET progress = ?, finish = ? WHERE identifier = ? AND mission_id = ?', {data.progress, data.finish, id, tonumber(mid)})
            end
        end
    end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	local xPlayer = ESX.GetPlayerFromId(playerId)
        for mid, data in pairs(cache[xPlayer.identifier]) do 
            MySQL.update('UPDATE mission SET progress = ?, finish = ? WHERE identifier = ? AND mission_id = ?', {data.progress, data.finish, xPlayer.identifier, tonumber(mid)})
        end
        cache[xPlayer.identifier] = nil
end)


--debug
RegisterCommand('givemission', function(source)
    givemission()
end, true)

RegisterCommand('givepoint', function(source, arg)
    local xPlayer = ESX.GetPlayerFromId(arg[1])
    TriggerEvent('0mission0:getPointforMission', arg[2], arg[3], xPlayer)
end, true)

RegisterCommand('refreshmission', function()
    for id, mis in pairs(cache) do
        for mid, data in pairs(mis) do 
            MySQL.update('UPDATE mission SET progress = ?, finish = ? WHERE identifier = ? AND mission_id = ?', {data.progress, data.finish, id, tonumber(mid)})
        end
    end
end, true)

--give mission
function givemission(d, h, m)
    if Config.interval ~= 'daily' and d and days[Config.interval] ~= d then
        return
    end
    MySQL.Sync.execute(
        "DELETE FROM `mission`; "
    )
    cache = {}
    local players = ESX.GetPlayers()
    for _, ply in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(ply)
        local t = {}
        cache[xPlayer.identifier] = {}
        math.randomseed(os.time())
        local found = false
        for i=1, Config.missionNo do
            repeat
            found = false
            n = math.random(1, #mission)
            for a=1, i do
                if t[a] == n then
                    found = true
                end
            end
            Citizen.Wait(0)
            until (found == false)
            MySQL.insert('INSERT INTO `mission` (`mission_id`, `max`, `identifier`) VALUES(?, ?, ?)', {n, mission[n].max, xPlayer.identifier})
            t[i] = n
            local data = {progress = 0, max = mission[n].max, finish = 0}
            cache[xPlayer.identifier][tostring(n)] = data
        end
    end
    TriggerClientEvent('0mission0:forceClose', -1)
end

TriggerEvent('cron:runAt', Config.time, 0, givemission)

AddEventHandler('onResourceStart', function(resource)
    Citizen.Wait(1000)
    local players = ESX.GetPlayers()
    for _, ply in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(ply)
        cache[xPlayer.identifier] = {}
    local result = MySQL.query.await('SELECT * FROM mission WHERE identifier = ?', {xPlayer.identifier})
    if #result < Config.missionNo then
        local t = {}
        math.randomseed(os.time())
        local found = false
        for i=1, (Config.missionNo- #result) do
            repeat
            found = false
            n = math.random(1, #mission)
            for a=1, i do
                if t[a] == n then
                    found = true
                end
            end
            Citizen.Wait(0)
            until (found == false)
            MySQL.insert('INSERT INTO `mission` (`mission_id`, `max`, `identifier`) VALUES(?, ?, ?)', {n, mission[n].max, xPlayer.identifier})
            t[i] = n
            local data = {progress = 0, max = mission[n].max, finish = 0}
            cache[xPlayer.identifier][tostring(n)] = data
        end
        if #result < 0 then
            for i=1, #result do
                local n = result[i].mission_id
                local data = {progress = result[i].progress, max = result[i].max, finish = result[i].finish}
                cache[xPlayer.identifier][tostring(n)] = data
            end
        end
    else
        for i=1, Config.missionNo do
            local n = result[i].mission_id
            local data = {progress = result[i].progress, max = result[i].max, finish = result[i].finish}
            cache[xPlayer.identifier][tostring(n)] = data
        end
    end
end
end)
