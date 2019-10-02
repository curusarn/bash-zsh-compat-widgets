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

bindfunc '\C-i' "mywidget_compat"  
bindfunc '\C-o' "mywidget_compat2"  