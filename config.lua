Config = {}

Config.oldESX = false --set true if you need ESX initiation

Config.missionNo = 3 --must be equal to or less than the total number of missions in mission.lua

--update setting

Config.interval = 'wed' --mon / tue / wed / thu / fri / sat / sun / daily

Config.time = 0 -- hour (e.g. 0 = update at 00:00)

--locale

Config.finish = '0mission0: Mission Completed'

Config.update = 'Updating mission, panel is forced to close'

Config.NuiLocale = {
    get = 'Claim',
    got = 'Claimed'
}

--reward
giveReward = function(mid, source, xPlayer)
    if mid == 1 then
        xPlayer.addMoney(5000)
    else
        xPlayer.addMoney(1000)
    end
end