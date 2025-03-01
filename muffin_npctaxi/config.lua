config = config or {}

config.debug = true                -- Debug

config.mlogs = true                -- Using muffin_logs?

config.TaxiVehicle = "taxi"        -- Taxi vehicle model
config.Fee = 50                    -- Fee for the ride
config.CostPerMeter = 5            -- Extra fee for the ride

config.pos = vector4(-59.55, -777.05, 44.21, 240.11)    -- position for the car to spawn
config.pedpos = vector4(-61.67, -781.28, 44.23, 250.34) -- position for the NPC to spawn