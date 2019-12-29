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

bindfunc --revert '\C-p' "mywidget_compat"
# shellcheck disable=SC2034
revert_ctrl_p=$_bindfunc_revert
# shellcheck disable=SC2016
echo 'Run `eval $revert_ctrl_p` to revert Control+P binding'

bindfunc --revert '\C-r' "mywidget_compat2"
# shellcheck disable=SC2034
revert_ctrl_r=$_bindfunc_revert
# shellcheck disable=SC2016
echo 'Run `eval $revert_ctrl_r` to revert Control+R binding'