local command = require 'config.command'

CreateThread(function ()
    TriggerEvent('chat:addSuggestions', command)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, data in pairs(command) do
            TriggerEvent('chat:removeSuggestion', data.name)
        end
    end
end)