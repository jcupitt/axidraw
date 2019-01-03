# Notes

This needs the `axicli` program.

## Installation notes for 2.3.0 on macOS Mojave

```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
cd axidraw-api_v230_b1
pip install . --user
alias axicli="axicli --model 2"
cp axicli.py ~/Library/Python/2.7/bin/axicli
chmod +x ~/Library/Python/2.7/bin/axidraw
```

## Drawing the plot

To disable motors and raise pen:

```
axicli curves.svg --mode align
```

To plot layer 1, low speed (default pen speed is 25):

```
axicli curves.svg --pen_pos_down 0 --pen_pos_up 90 --speed_pendown 15 --mode layers --layer 2
```
