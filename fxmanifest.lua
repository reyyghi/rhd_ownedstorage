fx_version 'adamant'

game 'gta5'
atuhor 'Reyghita Hafizh & Della'
lua54 'yes'

client_scripts {
    'client/cl_*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/sh_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua'
}

files {
    'locales/*.json',

    'data/storage.json'
}