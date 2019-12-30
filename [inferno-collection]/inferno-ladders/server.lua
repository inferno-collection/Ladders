-- Inferno Collection Ladders Version 1.0 Alpha
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

RegisterServerEvent("Ladders:StoreLadder")
AddEventHandler("Ladders:StoreLadder", function(LadderNetID)
	if not Ladders[LadderNetID] then
        Ladders[LadderNetID] = {}
        Ladders[LadderNetID].ID = LadderNetID

        TriggerClientEvent("Ladders:Bounce:ServerValues", -1, Ladders)
	end
end)

RegisterServerEvent("Ladders:UpdateLadder")
AddEventHandler("Ladders:UpdateLadder", function(LadderNetID, Key, Value)
	if Ladders[LadderNetID] then
        Ladders[LadderNetID][Key] = Value

        TriggerClientEvent("Ladders:Bounce:ServerValues", -1, Ladders)
    end
end)

RegisterServerEvent("Ladders:DropLadder")
AddEventHandler("Ladders:DropLadder", function(LadderNetID)
    if Ladders[LadderNetID] then
        if Ladders[LadderNetID].BeingCarried then
            TriggerClientEvent("Ladders:Return:DropLadder", source)
        end
    end
end)

RegisterServerEvent("Ladders:PlaceLadder")
AddEventHandler("Ladders:PlaceLadder", function(LadderNetID)
    if Ladders[LadderNetID] then
        if Ladders[LadderNetID].BeingCarried then
            TriggerClientEvent("Ladders:Return:PlaceLadder", source)
        end
    end
end)

RegisterServerEvent("Ladders:Pickup")
AddEventHandler("Ladders:Pickup", function(LadderNetID)
    if Ladders[LadderNetID] then
        if not Ladders[LadderNetID].BeingCarried and not Ladders[LadderNetID].BeingClimbed then
            TriggerClientEvent("Ladders:Return:Pickup", source, LadderNetID)
        end
    end
end)

RegisterServerEvent("Ladders:Climb")
AddEventHandler("Ladders:Climb", function(LadderNetID, Dirrection)
    if Ladders[LadderNetID] then
        if Ladders[LadderNetID].Placed and not Ladders[LadderNetID].BeingClimbed then
            TriggerClientEvent("Ladders:Return:Climb", source, LadderNetID, Dirrection)
        end
    end
end)

RegisterServerEvent("Ladders:DeleteLadder")
AddEventHandler("Ladders:DeleteLadder", function(LadderNetID)
    if Ladders[LadderNetID] then
        TriggerClientEvent("Ladders:Return:DeleteLadder", source)

        Citizen.Wait(1000)

        Ladders[LadderNetID] = nil

        TriggerClientEvent("Ladders:Bounce:ServerValues", -1, Ladders)
	end
end)