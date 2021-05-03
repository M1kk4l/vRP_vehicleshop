local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

RegisterServerEvent('vehicleshop:buyVeh')
AddEventHandler('vehicleshop:buyVeh', function(vehicle, vehicle_name, price)
    veh_type = "car"
    local user_id = vRP.getUserId({source})
    local player = vRP.getUserSource({user_id})
    MySQL.Async.fetchAll("SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle", {user_id = user_id, vehicle = vehicle}, function(pvehicle, affected)
		vRP.prompt({player,"Er du sikker på, at du vil købe køretøjet? (ja/nej)","",function(player,answer)
			if string.lower(answer) == "ja" then
			if #pvehicle > 0 then
				TriggerClientEvent("pNotify:SendNotification", player,{text = "Du ejer allerede dette køretøj.", type = "error", queue = "global", timeout = 4000, layout = "centerLeft",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},killer = true})
			else
					if vRP.tryFullPayment({user_id,price}) then
					  	vRP.getUserIdentity({user_id, function(identity)
							MySQL.Async.execute("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,vehicle_name,vehicle_plate,veh_type,vehicle_price) VALUES(@user_id,@vehicle,@vehicle_name,@vehicle_plate,@veh_type,@vehicle_price)",{["@user_id"] = user_id, vehicle = vehicle, vehicle_name = vehicle_name, vehicle_plate = "P"..identity.registration, veh_type = veh_type, vehicle_price = price})   
						end})

						TriggerClientEvent('vehicleshop:CloseMenu', player, vehicle, veh_type)
						TriggerClientEvent("pNotify:SendNotification", player,{text = "Du betalte <b style='color: #DB4646'>"..price.." DKK</b> for en " ..vehicle_name, type = "error", queue = "global", timeout = 4000, layout = "centerLeft",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},killer = true})
					else
						TriggerClientEvent("pNotify:SendNotification", player,{text = "Du har ikke råd til at købe dette køretøj.", type = "error", queue = "global", timeout = 4000, layout = "centerLeft",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},killer = true})
					  end
				end
			else
				TriggerClientEvent("pNotify:SendNotification", player,{text = "Købet blev afbrudt, da du ikke bekræftede købet.", type = "error", queue = "global", timeout = 5000, layout = "centerLeft",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
			end
		end})
    end)
end)