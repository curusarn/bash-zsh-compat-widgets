# bash-zsh-compat-widgets

This project enables you to use the same function as both:

- Zsh ZLE widget
- Bash readline "widget"

## Bindfunc

Bash uses `bind -x ...` to bind "widgets".

Zsh uses `zle -N ...` and then `keybind ...` to bind widgets.

`bindfunc` is a wrapper around these commands that binds widgets in both bash and zsh.

Use it like this:

```sh
bindfunc KEY_SEQUENCE SHELL_FUNCTION
```

If you need to be able to revert the binding later do it like this:

```sh
bindfunc --unbind KEY_SEQUENCE SHELL_FUNCTION
revert_bind=$_bindfunc_revert

# do whatever

eval $revert_bind
```

*I know what you are thinking. Using `eval` is ugly and dangerous but just as in the case of `eval $(ssh-agent)` using `eval` is the best solution here.*

You can find more examples at the bottom of this page.

## Compatibility wrapper

Part of this project is a very simple compatibility layer that makes it possible to use simple zsh zle widgets in bash and all bash "widgets" in zsh.

Use it like this:

```sh
mywidget_compat() {
    __bindfunc_compat_wrapper mywidget_zsh
}
```

## Example

Full example showing how to use this project:

```sh
source bindfunc.sh

mywidget_bash() {
    READLINE_LINE="# This was written by a bash readline \"widget\""
}

mywidget_zsh() {
    BUFFER="# This was written by a zsh zle widget"
}

mywidget_compat() {
    __bindfunc_compat_wrapper mywidget_bash
}

mywidget_compat2() {
    __bindfunc_compat_wrapper mywidget_zsh
}

bindfunc '\C-o' "mywidget_compat"  
bindfunc '\C-p' "mywidget_compat2"  
```

Just run `source example.sh` in your terminal and press `Control-O` or `Control-P` to see it in practice.

There is a second `example_unbind.sh` that shows how you can revert the bindings.

1) activate the bindings by running `source example_unbind.sh`
1) press `Control-R` or `Control-P` to use them
1) revert the bindings with `eval $revert_ctrl_r` and `eval $revert_ctrl_p`