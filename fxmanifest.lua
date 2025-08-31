fx_version 'cerulean'
game 'gta5'

name 'gs-vendrob'
author 'NRG Development'
description 'Advanced Vending Machine Robbery Script with QBCore, QBX, and ESX compatibility'
version '1.0.0'

shared_scripts {
    'config/config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

lua54 'yes'