fx_version 'adamant'

game 'gta5'
atuhor 'Reyghita Hafizh & Della'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'bridge/shared.lua',
    'bridge/framework/*.lua',
    'bridge/target/*.lua',
    'bridge/inventory/*.lua',
    'bridge/notify/*.lua',
}

client_scripts {
    'client/cl_*.lua'
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua'
}

ox_lib "locale"

files {
    'config/perms.lua',
    'config/command.lua',
    'data/stash.lua',
    'data/prop.lua',
}
