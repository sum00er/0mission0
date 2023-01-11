# 0mission0
weekly / daily mission script for ESX FiveM servers

To add points for mission, trigger the server event
觸發伺服器事件來給予任務分數

from server 從伺服器端:
```
local xPlayer = ESX.GetPlayerFromId(source)
TriggerEvent('0mission0:getPointforMission', [mission id], [point], xPlayer)
```

from client 從客戶端:
```
TriggerServerEvent('0mission0:getPointforMission', [mission id], [point])
```

Debug command:
|                                         |                                              |
|-------------------------------------|-----------------------------------------|
| /givemission       | updates mission 手動更新任務  |
| /givepoint (player id) (mission id} (point)     | give points to player for a specific mission 手動給予特定任務的分數   |
| /refreshmission | save mission progress to db 手動儲存任務數據到資料庫  |
