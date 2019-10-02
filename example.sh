source bindfunc.sh

mywidget_bash() {
    READLINE_LINE="# This was written by a bash readline \"widget\""
    READLINE_POINT=3
}

mywidget_zsh() {
    BUFFER="# This was written by a zsh zle widget"
    CURSOR=3
}

mywidget_compat() {
    __bindfunc_compat_wrapper mywidget_bash
}

mywidget_compat2() {
    __bindfunc_compat_wrapper mywidget_zsh
}

bindfunc '\C-o' "mywidget_compat"  
bindfunc '\C-p' "mywidget_compat2"  