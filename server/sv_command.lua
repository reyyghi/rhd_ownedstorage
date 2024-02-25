local command = require 'config.command'

CreateThread(function ()
    for index, data in pairs(command) do
        RegisterCommand(data.name, function (playerId)
            Perms.get(playerId, function (authorized)
                if authorized then
                    TriggerClientEvent(data.event, playerId)
                end
            end)
        end, false)
    end
end)