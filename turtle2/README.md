# Notes

This needs the `axicli` program. Install with:

```
python -m pip install https://cdn.evilmadscientist.com/dl/ad/public/AxiDraw_API.zip
alias axicli="axicli --model 2"
```

## Drawing the plot

To disable motors and raise pen:

```
axicli --mode align
```

To plot layer 1, low speed (default pen speed is 25):

```
axicli drawing.svg --pen_pos_down 0 --pen_pos_up 90 --speed_pendown 15 --mode layers --layer 1
```

Or just:

```
./draw_layer 1
```
