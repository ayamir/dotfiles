# Contributing to dwm-bar
One goal of this project is to support as many (reasonable) plugins as possible which the user can enable or disable depending on their needs. This means that new plugins will almost always be a welcome addition.
To ensure that dwm-bar stays compatible, uniform, and efficient there are a few guidelines that should be followed.

The most important part of this project is to have fun using shell scripts. I created this project to learn, and learning only happens when mistakes are made, so don't worry too much.
## Making/editing a plugin
* Ensure that plugins are POSIX compliant (use ```#!/bin/sh``` instead of ```#!/bin/bash``` etc.). A good way to check this is by using [ShellCheck](https://www.shellcheck.net/) on your script and amending compatibility errors.
* Display plugin output in the terminal. This is easily done by wiriting the plugin in a function and calling the function at the end of the script. This helps with debugging and spotting errors.
* Include a dependencies section at the top of the script (```Dependencies: example1, example2```).
## Editing dwm_bar.sh
* Do not remove functions from the main script.
## Editing README.md
* When adding a plugin to README.md, follow this template:
```
    ### plugin_name
    Description of the plugin
    ```
    [❗ Plugin output on bar]
    ```
    Dependencies: example1, example2
```
* Ensure additons are added to the table of contents:
```
- [Current Functions])(#current-functions)
  -[plugin_name](#plugin_name)
```
