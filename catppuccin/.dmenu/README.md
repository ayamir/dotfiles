# dmenu Arc

This is my configuration of [dmenu-flexipatch](https://github.com/bakkeby/dmenu-flexipatch) with a bunch of patches enabled.

## Preview

![Preview of dmenu](https://raw.githubusercontent.com/Zaedus/dmenu-arc/master/preview.png)

## General Info

Not a whole lot of information is going to be on here, so go to the [main repo](https://github.com/Zaedus/arc-dotfiles) for more info.

## Patches

- CENTER_PATCH
- FUZZYHIGHLIGHT_PATCH
- FUZZYMATCH_PATCH
- GRID_PATCH
- HIGHLIGHT_PATCH
- HIGHPRIORITY_PATCH
- LINE_HEIGHT_PATCH
- MOUSE_SUPPORT_PATCH
- NUMBERS_PATCH
- SCROLL_PATCH
- VERTFULL_PATCH
- XYW_PATCH

## Modifying

To modify this, I highly recommend reading the [https://github.com/bakkeby/dwm-flexipatch#readme](flexipatch README).

### Things to Know Before Editing

- I edited the `config.def.h` which means you should run `make` and then edit the `config.h`