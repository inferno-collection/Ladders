-- Inferno Collection Ladders Version 1.1 Alpha
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

local Ladders = {}
local Vehicles = {}

RegisterServerEvent("Ladders:Server:Ladders")
AddEventHandler("Ladders:Server:Ladders", function(Action, LadderNetID, Key, Value)
    if Action == "store" and not Ladders[LadderNetID] then
        Ladders[LadderNetID] = {}
        Ladders[LadderNetID].ID = LadderNetID
    elseif Ladders[LadderNetID] then
        if Action == "update" then
            Ladders[LadderNetID][Key] = Value
        elseif Action == "pickup" then
            if not Ladders[LadderNetID].BeingCarried and not Ladders[LadderNetID].BeingClimbed then
                TriggerClientEvent("Ladders:Client:Pickup", source, LadderNetID)
            end
        elseif Action == "climb" then
            if Ladders[LadderNetID].Placed and not Ladders[LadderNetID].BeingClimbed then
                TriggerClientEvent("Ladders:Client:Climb", source, LadderNetID, Key)
            end
        elseif Action == "delete" then
            Ladders[LadderNetID] = nil
        elseif Ladders[LadderNetID].BeingCarried then
            if Action == "drop" then
                TriggerClientEvent("Ladders:Client:DropLadder", source)
            elseif Action == "place" then
                TriggerClientEvent("Ladders:Client:PlaceLadder", source)
            end
        end
    end

    TriggerClientEvent("Ladders:Bounce:ServerValues", -1, Ladders)
end)

RegisterServerEvent("Ladders:Server:Vehicles")
AddEventHandler("Ladders:Server:Vehicles", function(Action, Vehicle, Max, ToRemove)
    if Action == "check" then
        if not Vehicles[Vehicle] then
            Vehicles[Vehicle] = Max
        end

        TriggerClientEvent("Ladders:Client:VehicleCheck", source, Vehicle, Vehicles[Vehicle], Max, ToRemove)
    elseif Vehicles[Vehicle] then
        if Action == "add" then
            Vehicles[Vehicle] = Vehicles[Vehicle] + 1
        elseif Action == "remove" then
            Vehicles[Vehicle] = Vehicles[Vehicle] - 1
        end
    end
end)