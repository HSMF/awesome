# Awesome dotfiles

it's awesome

## Per-Setup Configuration

Running awesome for the first time should create [~/.config/awesome/user-configs.lua](~/.config/awesome/user-configs.lua).

The following keys are supported in user-config:

```lua
my_config.spotify_wallpapers = {
  artist_name:string = filename:string
}
my_config.default_wallpaper = wallpaper_path:string
my_config.gaps = gap_size:integer
```

## Packages

- `playerctl`
- `luarocks`

### Fonts

install those:

- `noto-fonts-cjk`
- `ttf-material-icons-git`
- `ttf-icomoon-feather`
- `ttf-material-icons-git`
- `ttf-typicons`

### Luarocks packages

```sh
luarocks install lain
```

### Other

- rofi theme: [catppuccin/rofi](https://github.com/catppuccin/rofi)

## Credits

this config is currently strongly influenced by [elenapan/dotfiles](https://github.com/elenapan/dotfiles)
