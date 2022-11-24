# Skiptro for VLC

Skiptro is a VLC extension that allows you to skip to the parts that matter in a movie or TV show. For more information, visit [skiptro.app](https://skiptro.app).

## Running

Compile with
`vlc -I luaintf --lua-intf luac --lua-config 'luac={input="~/skiptro-vlc/src/skiptro_intf.lua",output="skiptro_intf.luac"}'`

Copy to `~/Library/Application Support/org.videolan.vlc/lua/intf`

Run with `vlc --extraintf=luaintf --lua-intf=skiptro_intf`
