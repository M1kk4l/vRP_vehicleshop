local Vehicles
local Categories

Citizen.CreateThread(function()
    while Vehicles == nil or Categories == nil do
        Citizen.Wait(100)
        Vehicles = cfg.vehicles
        Categories = cfg.categories
        for i,vehicles in pairs(Vehicles) do
            vehicles.maxSpeed = round(GetVehicleModelMaxSpeed(vehicles.model)*3.6)
            vehicles.seats = GetVehicleModelNumberOfSeats(vehicles.model)
            for n,categories in pairs(Categories) do
                if vehicles.category == categories.name then
                    vehicles.categoryLabel = categories.label
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleeptimer = 500
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg.pos, true) < 15 then
            sleeptimer = 0
            DrawMarker(27, cfg.pos.x,cfg.pos.y,cfg.pos.z-0.99, 0, 0, 0, 0, 0, 0,  1.2,  1.2, 1.2, 173, 16, 10, 255, false, false, false, true)
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cfg.pos, true) < 1 then
                DrawText3D(cfg.pos,"[~b~E~w~] Tilgå Bilforhandler.")
                if IsControlJustPressed(1, 38) then
                    OpenShopMenu()
                end
            end
        end
        Citizen.Wait(sleeptimer)
    end
end)

RegisterNUICallback('CloseMenu', function(data, cb)
    SetNuiFocus(false, false)
	cb(false)
end)

RegisterNUICallback('TestDrive', function(data, cb) 
	SetNuiFocus(false, false)
	local model = data.model
    local oldCoords = GetEntityCoords(PlayerPedId())
    local timer = 0
    SetEntityCoords(PlayerPedId(), cfg.testpos, 0, 0, 0, true)
    local veh = spawnCar(data.model,cfg.testpos,50,true)
    while timer < cfg.timer do
        timer = timer+1
        Citizen.Wait(1000)
    end
    SetEntityCoords(PlayerPedId(), oldCoords, 0, 0, 0, true)
    DeleteVehicle(veh)
end)

RegisterNUICallback('BuyVehicle', function(data, cb)
    SetNuiFocus(false, false)
    local model = data.model
    for i,v in pairs(Vehicles) do
        if v.model == data.model then
            data.label = v.name
            data.price = v.price
        end
    end
	TriggerServerEvent("vehicleshop:buyVeh", data.model,data.label,data.price)
end)

function OpenShopMenu()
	local vehicle = {}
	SetNuiFocus(true, true)
		
	SendNUIMessage({
        show = true,
		cars = Vehicles,
		categories = Categories
    })
end

function round(num, numDecimalPlaces)
    local mult = 100^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function DrawText3D(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    -- Experimental math to scale the text down
    local scale = 200 / (GetGameplayCamFov() * dist)

    SetTextColour(230, 230, 230, 255)
    SetTextScale(0.35, 0.35)
    SetTextFont(0)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(1)

    -- Diplay the text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()

end

function spawnCar(model,coords,h,spawnIN)
    while not HasModelLoaded(model) do RequestModel(model) Citizen.Wait(100) end
    while GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true) > 50 do Citizen.Wait(100) end
    local car = CreateVehicle(GetHashKey(model), coords, h, 1,0)
    PlaceObjectOnGroundProperly(car)
    if spawnIN then
        TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
    end
    local id = NetworkGetNetworkIdFromEntity(car)
    SetEntityAsMissionEntity(car,true,true)
    return car
end