# Notes

This needs the `axicli` program since it relies on the better clipping
supported there.

## Installation notes for 2.2.0 on macOS Mojave

Although `axicli` works with most Python versions, Inkscape 0.91, the version
recommended for Axidraw, is python2.7 only. macOS does not include `pip`, so you
need to install it. See:

    https://pip.readthedocs.io/en/stable/installing/

tldr:

```bash
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
```

That will install `pip` to `$HOME/Library/Python/2.7/bin`, so you'll need
to add that to your `PATH`:

```bash
export PATH=$HOME/Library/Python/2.7/bin:$PATH
```

As per the `axicli` notes, you need lxml:

```bash
pip install lxml --user
```

`axicli` imports `inkex.py`, the Inkscape extension base class. You therefore
need to have Inkscape's extension folder in your `PYTHONPATH`. Add this to your
`.bash_profile`:

```bash
export INKSCAPEHOME=/Applications/Inkscape.app/Contents/Resources
export PYTHONPATH=$INKSCAPEHOME/share/inkscape/extensions:$PYTHONPATH
```

Adjusting `INKSCAPEHOME` appropriately.

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
