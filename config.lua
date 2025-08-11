Config = {}

Config.onStart = function()
    -- Use this to disable ox_inventory during the execution of the script
    LocalPlayer.state.invBusy = false
    exports["ox_inventory"]:weaponWheel(false)
end

Config.onStop = function()
    -- Use this to enable ox_inventory after the execution of the script
    LocalPlayer.state.invBusy = false
    exports["ox_inventory"]:weaponWheel(false)

    TriggerEvent("esx_ambulancejob:revive") -- Revive the player
    ExecuteCommand("clear") -- Clear the chat
end

Config.ChatText = "ALVARO ON TOP"