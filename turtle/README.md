# Turtle graphics on the axidraw

Generate:

```
./star.rb
```

Preview:

```
open drawing.svg
```

Motors off:

```
axicli -m align drawing.svg
```

Plot layer 1:

`-s 15` means max speed 15 (default is 25)

```
axicli -m layers -d 10 -u 90 -l 1 -s 15 drawing.svg
```

