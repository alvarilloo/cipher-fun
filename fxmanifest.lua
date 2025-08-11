fx_version "cerulean"
game "gta5"

author "alvaro.16_"
description "A recreation of the visual spam from the backdoor known in FiveM as Cipher."
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}

ui_page "ui/index.html"

files {
    "ui/cipher.mp3",
    "ui/index.html",
    "ui/script.js",
    "ui/style.css",
    "ui/e.png"
}

dependency 'ox_lib'