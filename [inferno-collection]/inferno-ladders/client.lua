-- Inferno Collection Ladders Version 1.3 Alpha
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
--
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--

local Config = {} -- Do not edit this line

-- Model names of Vehicles that ladders can be collected from, and how many ladders they have
Config.Vehicles = {
    firetruk = 2
}

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Synced table accross all clients and the server
local Ladders = {}
-- Locally created ladders
local LocalLadders = {}

-- General variables
local Climbing = false
local Carrying = false
local ClimbingLadder = false
local Preview = false
local PreviewToggle = true
local Clipset = false
local ClimbingVectors = {
    up = {
        {vector3(0.0, -0.45, -1.5), 'laddersbase', 'get_on_bottom_front_stand_high'},
        {vector3(0.0, -0.3, -1.1), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, -0.7), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, -0.3), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 0.1), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 0.5), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 0.9), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 1.3), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 1.7), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.3, 2.1), 'laddersbase', 'climb_up'},
        {vector3(0.0, -0.4, 2.5), 'laddersbase', 'get_off_top_back_stand_left_hand'}
    },

    down = {
        {vector3(0.0, -0.4, 2.5), 'laddersbase', 'get_on_top_front'},
        {vector3(0.0, -0.3, 2.1), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, 1.7), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, 1.3), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, 0.9), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, 0.5), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, 0.1), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, -0.3), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, -0.7), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.3, -1.1), 'laddersbase', 'climb_down'},
        {vector3(0.0, -0.45, -1.5), 'laddersbase', 'get_off_bottom_front_stand'}
    }
}

-- Gets all existing ladders for new players
AddEventHandler('onClientMapStart', function() TriggerServerEvent('Ladders:Server:PersonalRequest') end)

-- Ladder command
RegisterCommand('ladder', function(_, Args)
    if Args[1] then
        local Action = Args[1]:lower()

        if Action == 'collect' then
            if not Carrying then
                local Truck = TruckTest()

                if Truck then TriggerServerEvent('Ladders:Server:Vehicles', 'check', VehToNet(Truck[1]), Truck[2], false) end
            else
                NewNoti('~y~You already carrying a ladder!', true)
            end
        elseif Action == 'store' then
            if Carrying then
                local Truck = TruckTest()

                if Truck then TriggerServerEvent('Ladders:Server:Vehicles', 'check', VehToNet(Truck[1]), Truck[2], true) end
            else
                NewNoti('~y~You do not have a ladder out!', true)
            end
        else
            NewNoti('~r~Invalid action! Use: "collect" or "store".', true)
        end
    else
        NewNoti('~r~No action specified!', true)
    end
end)

RegisterNetEvent('Ladders:Client:VehicleCheck')
AddEventHandler('Ladders:Client:VehicleCheck', function(TruckNetID, LadderCount, Max, ToRemove)
    if ToRemove then
        if LadderCount < Max then
            TriggerServerEvent('Ladders:Server:Ladders:Local', 'remove')
            TriggerServerEvent('Ladders:Server:Vehicles', 'add', TruckNetID)

            NewNoti('~g~Ladder stored. This vehicle can store ' .. Max - (LadderCount - 1) .. ' more ladders.', false)
        else
            NewNoti('~r~This vehicle can only carry ' .. Max .. ' ladders!', true)
        end
    else
        if LadderCount > 0 then
            TriggerServerEvent('Ladders:Server:Ladders:Local', 'add')
            TriggerServerEvent('Ladders:Server:Vehicles', 'remove', TruckNetID)

            NewNoti('~g~Ladder collected from vehicle. This vehicle has ' .. LadderCount - 1 .. ' more ladders.', false)
        else
            NewNoti('~r~This vehicle has no more ladders!', true)
        end
    end
end)

-- Create ladders client side
RegisterNetEvent('Ladders:Client:Local:Add')
AddEventHandler('Ladders:Client:Local:Add', function(SourceId)
    local SourcePlayer = GetPlayerFromServerId(SourceId)
    local SourcePed = GetPlayerPed(SourcePlayer)

    if (SourcePed ~= -1 and not LocalLadders[SourcePed]) then
        local LadderCoords = GetOffsetFromEntityInWorldCoords(SourcePed, 0.0, 1.2, 1.32)
        local Ladder = CreateObjectNoOffset(GetHashKey('prop_byard_ladder01'), LadderCoords, false, false, false)
        SetEntityAsMissionEntity(Ladder)
        SetEntityCollision(Ladder, false, true)
        LocalLadders[SourcePed] = Ladder

        if GetPlayerServerId(PlayerId()) == SourceId then Carrying = Ladder end
    end
end)

-- Remove local ladder
RegisterNetEvent('Ladders:Client:Local:Remove')
AddEventHandler('Ladders:Client:Local:Remove', function(SourceId)
    local SourcePlayer = GetPlayerFromServerId(SourceId)
    local SourcePed = GetPlayerPed(SourcePlayer)

    if (SourcePed ~= -1 and LocalLadders[SourcePed]) then
        DeleteObject(LocalLadders[SourcePed])
        SetEntityAsNoLongerNeeded(LocalLadders[SourcePed])
        ClearPedTasksImmediately(PlayerPed)
        LocalLadders[SourcePed] = nil

        if GetPlayerServerId(PlayerId()) == SourceId then Carrying = nil end
    end
end)

-- Syncs table across all clients and server
RegisterNetEvent('Ladders:Bounce:ServerValues')
AddEventHandler('Ladders:Bounce:ServerValues', function(NewLadders) Ladders = NewLadders end)

RegisterNetEvent('Ladders:Client:DropLadder')
AddEventHandler('Ladders:Client:DropLadder', function()
    if Carrying then
        local PlayerPed = PlayerPedId()

        local Ladder = CreateObjectNoOffset(GetHashKey('prop_byard_ladder01'), GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 0.0, -500.0), true, false, false)
        local LadderNetID = ObjToNet(Ladder)
        SetEntityAsMissionEntity(LadderNetID)
        ClearPedTasksImmediately(PlayerPed)
        SetEntityRotation(Ladder, 0.0, 90.0, 90.0)
        SetEntityCoords(Ladder, GetOffsetFromEntityInWorldCoords(PlayerPed, 0.5, 0.0, 0.0))
        ApplyForceToEntity(Ladder, 4, 0.001, 0.001, 0.001, 0.0, 0.0, 0.0, 0, false, true, true, false, true)

        TriggerServerEvent('Ladders:Server:Ladders:Local', 'remove')
        TriggerServerEvent('Ladders:Server:Ladders', 'store', LadderNetID)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingCarried', true)

        -- Allow time to drop to the ground
        Citizen.Wait(1000)

        local LadderCoords = GetEntityCoords(Ladder)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingCarried', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingClimbed', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Dropped', true)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Placed', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'x', LadderCoords.x)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'y', LadderCoords.y)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'z', LadderCoords.z)
    end
end)

RegisterNetEvent('Ladders:Client:Pickup')
AddEventHandler('Ladders:Client:Pickup', function(LadderNetID)
    if not Carrying and NetworkDoesNetworkIdExist(LadderNetID) then
        NetworkRequestControlOfNetworkId(LadderNetID)
        while not NetworkHasControlOfNetworkId(LadderNetID) do
            Citizen.Wait(0)
        end

        local Ladder = NetToObj(LadderNetID)
        DeleteObject(Ladder)
        SetEntityAsNoLongerNeeded(Ladder)

        TriggerServerEvent('Ladders:Server:Ladders:Local', 'add')
        TriggerServerEvent('Ladders:Server:Ladders', 'delete', LadderNetID)

        ClearPedTasksImmediately(PlayerPedId())
    end
end)

RegisterNetEvent('Ladders:Client:PlaceLadder')
AddEventHandler('Ladders:Client:PlaceLadder', function()
    if Carrying then
        local PlayerPed = PlayerPedId()
        local PlayerRot = GetEntityRotation(PlayerPed)
        local Ladder = CreateObjectNoOffset(GetHashKey('prop_byard_ladder01'), GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 1.0, 0.0), true, false, false)
        local LadderNetID = ObjToNet(Ladder)
        local LadderCoords = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 1.2, 1.32)
        SetEntityAsMissionEntity(LadderNetID)

        TriggerServerEvent('Ladders:Server:Ladders:Local', 'remove')
        TriggerServerEvent('Ladders:Server:Ladders', 'store', LadderNetID)

        SetEntityCoords(Ladder, LadderCoords)
        SetEntityRotation(Ladder, vector3(PlayerRot.x - 20.0, PlayerRot.y, PlayerRot.z))
        FreezeEntityPosition(Ladder, true)

        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingCarried', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingClimbed', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Dropped', false)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Placed', true)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'x', LadderCoords.x)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'y', LadderCoords.y)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'z', LadderCoords.z)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Topz', LadderCoords.z + 5.0)
        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'Bottomz', LadderCoords.z - 5.0)
    end
end)

RegisterNetEvent('Ladders:Client:Climb')
AddEventHandler('Ladders:Client:Climb', function(LadderNetID, Direction)
    if not Carrying then
        local PlayerPed = PlayerPedId()
        local Ladder = NetToObj(LadderNetID)

        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingClimbed', true)

        Climbing = true
        ClimbingLadder = GetEntityRotation(Ladder)

        if not HasAnimDictLoaded('laddersbase') then
            RequestAnimDict('laddersbase')
            while not HasAnimDictLoaded('laddersbase') do
                Citizen.Wait(0)
            end
        end

        ClearPedTasksImmediately(PlayerPed)
        FreezeEntityPosition(PlayerPed, true)
        SetEntityCollision(Ladder, false, true)

        Climbing = 'rot'

        for Dir, Pack in pairs(ClimbingVectors) do
            if Direction == Dir then
                for _, Element in pairs(Pack) do
                    SetEntityCoordsNoOffset(PlayerPed, GetOffsetFromEntityInWorldCoords(Ladder, Element[1]), false, false, false)
                    TaskPlayAnim(PlayerPed, Element[2], Element[3], 2.0, 0.0, -1, 15, 0, false, false, false)

                    Citizen.Wait(850)
                end
            end
        end

        if Direction == 'up' then
            SetEntityCoordsNoOffset(PlayerPed, GetOffsetFromEntityInWorldCoords(Ladder, 0.0, 0.5, 4.0), false, false, false)
        elseif Direction == 'down' then
            SetEntityCoordsNoOffset(PlayerPed, GetOffsetFromEntityInWorldCoords(Ladder, 0.0, -0.9, -1.4), false, false, false)
        end

        ClearPedTasksImmediately(PlayerPed)
        FreezeEntityPosition(PlayerPed, false)
        SetEntityCollision(Ladder, true, true)

        Climbing = false

        TriggerServerEvent('Ladders:Server:Ladders', 'update', LadderNetID, 'BeingClimbed', false)
    end
end)

-- Draws notification on client's screen
function NewNoti(Text, Flash)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(Text)
    DrawNotification(Flash, true)
end

-- Draws hint on client's screen
function NewHint(Text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(Text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Check if ped is near a valid vehicle to collect a ladder from
function TruckTest()
    local PlayerPed = PlayerPedId()
    local PlayerCoords = GetEntityCoords(PlayerPed, false)
    local OffSet = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 10.0, 0.0)
    local RayCast = StartShapeTestRay(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, OffSet.x, OffSet.y, OffSet.z, 10, PlayerPed, 0)
    local _, _, RayCoords, _, RayEntity = GetRaycastResult(RayCast)

    if Vdist(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, RayCoords.x, RayCoords.y, RayCoords.z) < 3 then
        local Truck = GetEntityModel(RayEntity)

        for Vehicle, Max in pairs(Config.Vehicles) do
            local Key = GetHashKey(Vehicle)

            if Key == Truck then return {RayEntity, Max} end
        end

        NewNoti('~r~This vehicles does not carry ladders!', true)
        return false
    else
        NewNoti('~r~No ladder carrying vehicle found!', true)
        return false
    end
end

-- Gets distance between player and provided coords
function GetDistanceBetween(Coords)
	return Vdist(GetEntityCoords(PlayerPedId(), false), Coords.x, Coords.y, Coords.z) + 0.01
end

-- Resource Master Loop
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)

        local PlayerPed = PlayerPedId()

        if not Carrying then
            if Clipset then
                Clipset = false
                ResetPedMovementClipset(PlayerPed, 0)
            end

            for _, Ladder in pairs(Ladders) do
                -- Return seems to oscillate between `number` and `table`, unclear why
                if type(Ladder) == 'table' then
                    if not Ladder.BeingCarried and Ladder.x and Ladder.y and Ladder.z then
                        if Ladder.Dropped then
                            if GetDistanceBetween(Ladder) <= 2.0 then
                                NewHint('~INPUT_PICKUP~ Pick up ladder')

                                if IsControlJustPressed(0, 38) then TriggerServerEvent('Ladders:Server:Ladders', 'pickup', Ladder.ID) end

                                break
                            end
                        elseif not Ladder.Dropped and Ladder.Placed and not Climbing then
                            if GetDistanceBetween(Ladder) <= 4 then
                                DisableControlAction(0, 23, true) -- Enter vehicle

                                local TopDistance = GetDistanceBetween(vector3(Ladder.x, Ladder.y, Ladder.Topz))
                                local BottomDistance = GetDistanceBetween(vector3(Ladder.x, Ladder.y, Ladder.Bottomz))

                                NewHint('~INPUT_PICKUP~ Climb ladder\n~INPUT_ENTER~ Pick up ladder')

                                -- If player is closer to the bottom than the top
                                if IsControlJustPressed(0, 38) then
                                    if TopDistance > BottomDistance then
                                        TriggerServerEvent('Ladders:Server:Ladders', 'climb', Ladder.ID, 'up')
                                    else
                                        TriggerServerEvent('Ladders:Server:Ladders', 'climb', Ladder.ID, 'down')
                                    end
                                elseif IsDisabledControlJustPressed(0, 23) then
                                    TriggerServerEvent('Ladders:Server:Ladders', 'pickup', Ladder.ID)
                                end

                                break
                            end
                        end
                    end
                end
            end

            if Preview then
                ResetEntityAlpha(Preview)
                DeleteObject(Preview)
                SetEntityAsNoLongerNeeded(Preview)
                Preview = false
            end
        else
            if IsPedRunning(PlayerPed) or IsPedSprinting(PlayerPed) then
                if not Clipset then
                    Clipset = true

                    if not HasAnimSetLoaded('MOVE_M@BAIL_BOND_TAZERED') then
                        RequestAnimSet('MOVE_M@BAIL_BOND_TAZERED')
                        while not HasAnimSetLoaded('MOVE_M@BAIL_BOND_TAZERED') do
                            Wait(0)
                        end
                    end

                    SetPedMovementClipset(PlayerPed, 'MOVE_M@BAIL_BOND_TAZERED', 1.0)
                end
            elseif Clipset then
                Clipset = false
                ResetPedMovementClipset(PlayerPed, 1.0)
            end

            NewHint('~INPUT_PICKUP~ Place ladder\n~INPUT_ENTER~ Drop ladder\n~INPUT_MP_TEXT_CHAT_TEAM~ Toggle preview')
            if IsControlJustPressed(0, 38) then
                TriggerEvent('Ladders:Client:PlaceLadder')
            elseif IsDisabledControlJustPressed(0, 23) then
                TriggerEvent('Ladders:Client:DropLadder')
            elseif IsControlJustPressed(0, 246) then
                if PreviewToggle then
                    PreviewToggle = false
                    PlaySoundFrontend(-1, 'NO', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
                else
                    PreviewToggle = true
                    PlaySoundFrontend(-1, 'YES', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
                end
            end

            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 23, true) -- Enter vehicle
            DisableControlAction(0, 24, true) -- Attack (LMB)
            DisableControlAction(0, 44, true) -- Take Cover
            DisableControlAction(0, 140, true) -- Attack (R)
            DisableControlAction(0, 141, true) -- Attack (Q)
            DisableControlAction(0, 142, true) -- Attack (LMB)
            DisableControlAction(0, 257, true) -- Attack (LMB)
            DisableControlAction(0, 263, true) -- Attack (R)
            DisableControlAction(0, 264, true) -- Attack (Q)

            if not Preview and PreviewToggle then
                local LadderCoords = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 1.2, 1.32)
                Preview = CreateObjectNoOffset(GetHashKey('prop_byard_ladder01'), LadderCoords, false, false, false)
                SetEntityCollision(Preview, false, false)
                SetEntityAlpha(Preview, 100)
            end

            if Preview and PreviewToggle then
                local LadderCoords = GetOffsetFromEntityInWorldCoords(PlayerPed, 0.0, 1.2, 1.32)
                local LadderRot = GetEntityRotation(PlayerPed)
                SetEntityCoords(Preview, LadderCoords, 1, 0, 0, 1)
                SetEntityRotation(Preview, vector3(LadderRot.x - 20.0, LadderRot.y, LadderRot.z), 2, true)
            end

            if Preview and not PreviewToggle then
                ResetEntityAlpha(Preview)
                DeleteObject(Preview)
                SetEntityAsNoLongerNeeded(Preview)
                Preview = false
            end

        end

        for SourcePed, Ladder in pairs(LocalLadders) do
            if (SourcePed ~= -1) then
                local Bone1 = GetEntityBoneIndexByName(SourcePed, 'BONETAG_NECK')
                local Bone2 = GetEntityBoneIndexByName(SourcePed, 'BONETAG_R_HAND')
                local LadderRot = GetWorldRotationOfEntityBone(SourcePed, Bone1);
                AttachEntityToEntity(Ladder, SourcePed, Bone2, 0.0, 0.0, 0.0, LadderRot.x + 20.0, LadderRot.y + 180.0, LadderRot.z + 90.0, false, false, flase, true, 0, false)
            end
        end

        if Climbing then
            if Climbing == 'rot' and ClimbingLadder then SetEntityRotation(PlayerPed, vector3(ClimbingLadder.x, ClimbingLadder.y, ClimbingLadder.z), 2, true) end

            DisableControlAction(0, 21, true) -- Sprint
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 23, true) -- Enter vehicle
            DisableControlAction(0, 24, true) -- Attack (LMB)
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 30, true) -- Move Right
            DisableControlAction(0, 31, true) -- Move Back
            DisableControlAction(0, 32, true) -- Move Forward
            DisableControlAction(0, 33, true) -- Move Back
            DisableControlAction(0, 34, true) -- Move Left
            DisableControlAction(0, 35, true) -- Move Right
            DisableControlAction(0, 44, true) -- Take Cover
            DisableControlAction(0, 140, true) -- Attack (R)
            DisableControlAction(0, 141, true) -- Attack (Q)
            DisableControlAction(0, 142, true) -- Attack (LMB)
            DisableControlAction(0, 257, true) -- Attack (LMB)
            DisableControlAction(0, 263, true) -- Attack (R)
            DisableControlAction(0, 264, true) -- Attack (Q)
            DisableControlAction(0, 266, true) -- Move Left
            DisableControlAction(0, 267, true) -- Move Right
            DisableControlAction(0, 268, true) -- Move Up
            DisableControlAction(0, 269, true) -- Move Down
        end

    end
end)