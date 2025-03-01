local QBCore = exports['qb-core']:GetCoreObject()
local taxi, driver
local notified = false -- Prevent notification spam
local isInTaxi = false -- Track if the player is in the taxi

RegisterNetEvent('qb_taxi:callTaxi')
AddEventHandler('qb_taxi:callTaxi', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local vehicleHash = GetHashKey(config.TaxiVehicle)
    local pedHash = GetHashKey('s_m_m_trucker_01')

    -- Load Vehicle Model
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(100)
    end

    -- Load Ped Model
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(100)
    end

    if config.debug then 
        print("~r~[Muffin NPC Taxi] = [DEBUG]~w~ Spawning Taxi vehicle and NPC")
    end

    -- Create Taxi and Driver
    taxi = CreateVehicle(vehicleHash, config.pos.x, config.pos.y, config.pos.z, config.pos.w, true, false)
    driver = CreatePed(5, pedHash, config.pedpos.x, config.pedpos.y, config.pedpos.z, config.pedpos.w, true, false)

    if DoesEntityExist(driver) then
        print("~r~[Muffin NPC Taxi] = [DEBUG]~w~ NPC driver spawned successfully")
        TaskWarpPedIntoVehicle(driver, taxi, -1)
    else
        print("~r~[Muffin NPC Taxi] = [ERROR]~w~ Failed to spawn NPC driver")
    end

    local playerSrc = GetPlayerServerId(PlayerId())
    local name = GetPlayerName(playerSrc)

    QBCore.Functions.Notify("A taxi is on its way!", "success")

    if config.mlogs == true then 
        TriggerServerEvent("muffin:taxi:sendlog", playerSrc)
    end 

    -- NPC Drive near the player
    TaskVehicleDriveToCoord(driver, taxi, playerCoords.x+2, playerCoords.y, playerCoords.z, 10.0, 0, config.TaxiVehicle, 786603, 1.0, true)
    
    -- Check if player is near the taxi
    Citizen.CreateThread(function()
        while true do
            local playerPos = GetEntityCoords(PlayerPedId())
            local taxiPos = GetEntityCoords(taxi)
            local distance = #(playerPos - taxiPos)

            if distance < 5.0 and not notified then
                QBCore.Functions.Notify("Press [E] to enter the taxi", "primary")
                notified = true
            end

            EnableControlAction(0, 38, true)

            if notified and IsControlJustReleased(0, 38) then
                print("~r~[Muffin NPC Taxi] = [DEBUG]~w~ Player pressed [E] to enter taxi")
                TaskEnterVehicle(playerPed, taxi, 10000, 2, 1.0, 1, 0)
                isInTaxi = true
                break
            end
            Wait(500)
        end
    end)
end)

-- Continuously check for waypoint while in taxi
Citizen.CreateThread(function()
    while true do
        if isInTaxi then
            local waypointBlip = GetFirstBlipInfoId(8)
            if DoesBlipExist(waypointBlip) then
                local coord = GetBlipInfoIdCoord(waypointBlip)
                QBCore.Functions.Notify("Heading to your selected waypoint", "success")
                TaskVehicleDriveToCoord(driver, taxi, coord.x, coord.y, coord.z, 15.0, 0, config.TaxiVehicle, 786603, 1.0, true)
                MonitorArrival(coord)
                isInTaxi = false
            end
        end
        Wait(1000)
    end
end)

function MonitorArrival(coord)
    Citizen.CreateThread(function()
        while true do
            local playerPos = GetEntityCoords(PlayerPedId())
            local distance = #(playerPos - coord)
            
            if distance < 10.0 then
                QBCore.Functions.Notify("You have arrived at your destination!", "success")
                TaskVehiclePark(driver, taxi, coord.x, coord.y, coord.z, 0.0, 0, 20.0, true)
                Wait(2000)
                TaskLeaveVehicle(PlayerPedId(), taxi, 0)
                TriggerServerEvent('qb_taxi:payFare', config.Fee)
                CleanupTaxi()
                break
            end
            Wait(500)
        end
    end)
end

function CleanupTaxi()
    if DoesEntityExist(driver) then
        DeletePed(driver)
    end
    if DoesEntityExist(taxi) then
        DeleteVehicle(taxi)
    end
    notified = false
    isInTaxi = false
    QBCore.Functions.Notify("Taxi has left.", "primary")
end

RegisterCommand("taxi", function()
    TriggerEvent('qb_taxi:callTaxi')
end, false)
