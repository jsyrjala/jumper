
# Taking screenshots

F12 takes a screen sho when running with `w4 watch`. The screenshot has resolution 160x160.
This command will correctly increase the image resolution.

```shell
convert screenshot.png -interpolate Nearest -filter point -resize 640x640 screenshot-big.png
```
