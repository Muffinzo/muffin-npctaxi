local QBCore = exports['qb-core']:GetCoreObject()

if config.debug == true then
    print("\27[31m[Muffin NPC Taxi] = [DEBUG]\27[0m QBCore loaded successfully!")
end

RegisterNetEvent('qb_taxi:payFare')
AddEventHandler('qb_taxi:payFare', function(fee)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.Functions.RemoveMoney("cash", fee, "paid-taxi") then
        TriggerClientEvent('QBCore:Notify', src, "You paid $" .. fee .. " for the taxi ride.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough money!", "error")
    end
end)

RegisterNetEvent("muffin:taxi:sendlog")
AddEventHandler("muffin:taxi:sendlog", function(playerSrc)
    exports["muffin_logs"]:SendLog("mnpctaxi",{
        color = 9044223,
        title = "[Muffin NPC Taxi] Taxi has been called",
        description = "A taxi has been called and is on the way by a " .. playerSrc .. " server ID",
    })

end)
