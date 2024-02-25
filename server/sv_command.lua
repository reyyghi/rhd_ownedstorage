lib.addCommand('buatgudang', {
    help = 'Untuk membuat gudang baru (Hanya Admin)',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent('rhd_os:client:createstash', source)
end)