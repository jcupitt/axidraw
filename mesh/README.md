# Iterative mesh generation

Inspired by a reddit post:

```
https://www.reddit.com/r/dataisbeautiful/comments/fbb9dt/oc_im_not_sure_if_it_fits_on_this_sub_but_i/
```

Generate:

```
./mesh.rb
```

Preview:

```
open mesh.svg
```

Motors off:

```
axicli -m align mesh.svg
```

Plot layer 0:

```
axicli -m layers -d 10 -u 90 -l 0 mesh.svg
```

