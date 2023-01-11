print("0mission0 by sum00er. https://discord.gg/pjuPHPrHnx")

local inMenu = false

if Config.oldESX then
    --esx initiation
    ESX = nil
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

--nui

RegisterCommand('mission', function()
    ESX.TriggerServerCallback('0mission0:getMission', function(cb)
        if cb then
            local missionData = {}
            for mid, data in pairs(cb) do
                local id = tonumber(mid)
                local title = mission[id].title
                local detail = {mission_id = id, title = title, finish = data.finish, max = data.max, progress = data.progress}
                table.insert(missionData, detail)
            end
                
            SetNuiFocus(true, true)
            SendNUIMessage({
                toggle = true,
                mission = json.encode(missionData),
                locale = Config.NuiLocale
            })
            inMenu = true
        end
    end)
end)

RegisterNetEvent('0mission0:updateNUI')
AddEventHandler('0mission0:updateNUI', function(mis, percent, ratio)
    local finish = false
    if percent == 1.0 then
        finish = true
    end
        
    SendNUIMessage({
        update = true,
        mission = mis,
        percent = percent,
        ratio = ratio,
        finish = finish,
        locale = Config.NuiLocale
    })
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false)
    SendNUIMessage({
        close = true
    })
    inMenu = false
end)

RegisterNetEvent('0mission0:forceClose')
AddEventHandler('0mission0:forceClose', function()
    if inMenu then
        SetNuiFocus(false)
        SendNUIMessage({
            close = true
        })
        ESX.ShowNotification(Config.update)
        inMenu = false
    end
end)

RegisterNUICallback('reward', function(data, cb)
    TriggerServerEvent('0mission0:reward', data.Id)
end)