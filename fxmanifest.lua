fx_version 'adamant'
game 'gta5'

version '1.2.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@vrp/lib/utils.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page "HTML/ui.html"

files {
    "HTML/ui.css",
    "HTML/ui.html",
	"HTML/ui.js",
}

exports {
	'OpenShopMenu'
}