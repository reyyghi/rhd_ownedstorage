fx_version 'adamant'

game 'gta5'
atuhor 'Reyghita Hafizh & Della'
lua54 'yes'

client_scripts {
    'bridge/**/cl_main.lua',
    'client/cl_*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'bridge/shared.lua',
    'shared/sh_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/**/sv_main.lua',
    'server/sv_*.lua'
}

files {
    'locales/*.json',

    'data/storage.json'
}
