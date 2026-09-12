fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Berk'
description 'next-fpsmenu'
version '1.0.0'

ui_page 'web/index.html'

files {
    'web/**/*.**',
    'web/*.**'
}

client_script 'client.lua'

shared_scripts {
    'Config.lua',
    'locales.lua'
}
