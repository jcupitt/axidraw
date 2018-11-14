# Notes

This needs the `axicli` program since it relies on the better clipping
supported there.

## Installation notes for 2.2.0 on macOS Mojave

```
brew install python3
pip3 install lxml 
alias axicli="python3 ~/packages/axidraw/axidraw-api-v2_2_0/axicli.py --model 2"
```

`axicli` only works if run from the source directory. Change this by editing
`axidraw-api-v2_2_0/pyaxidraw/axidraw_control.py` and changing the `path` code
to be:

```python
# Handle a few potential locations of this and its required files
this_dir = os.path.dirname(os.path.realpath(__file__))
libpath = os.path.join(this_dir, 'lib')
sys.path.append(this_dir)
sys.path.append(libpath)
```

The next version should fix this by making `pyaxidraw` into a pip package.

## Drawing the plot

Add this to your `.bash__profile`:

```bash
alias axicli="python ~/packages/axidraw/axidraw-api-v2_2_0/axicli.py --model 2"
```

Then to disable motors and raise pen:

```
axicli curves.svg --mode align
```

To plot layer 1:

```
axicli curves.svg --mode layers --layer 1
```
