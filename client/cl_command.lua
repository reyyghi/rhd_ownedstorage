local command = require 'config.command'

CreateThread(function ()
    for _, data in pairs(command) do
        TriggerEvent('chat:addSuggestion', ('/%s'):format(data.name), data.help)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, data in pairs(command) do
            TriggerEvent('chat:removeSuggestion', data.name)
        end
    end
end)