
__brw_bind_BUFFER() {
    # __brw_bind_arg=${__brw_bind_arg}'\e7' # save cursor
    # __brw_bind_arg=${__brw_bind_arg}'\e8' # restore cursor

    __brw_bind_arg=\''"\[15~": "'
    # clear the line w/o exiting vim mode
    for i in $(seq 0 ${#__brw_LINE}); do
        __brw_bind_arg=${__brw_bind_arg}'\e[C' # arrow right
        __brw_bind_arg=${__brw_bind_arg}'\b' # backspace
    done
    __brw_bind_arg=${__brw_bind_arg}"$BUFFER" # print buffer
    local offset=$((${#BUFFER} - $CURSOR - 1))
    for i in $(seq 0  $offset); do
        __brw_bind_arg=${__brw_bind_arg}'\e[D' # arrow left
    done
    __brw_bind_arg=${__brw_bind_arg}'"'\' # closing doublequote and quote
    printf 'bind %s' "${__brw_bind_arg}"
}

__brw_widget_exec() {
    __brw_LINE=$READLINE_LINE
    __brw_POINT=$READLINE_POINT
    BUFFER=$READLINE_LINE
    CURSOR=$READLINE_POINT
    LBUFFER=${BUFFER:0:CURSOR}
    RBUFFER=${BUFFER:CURSOR}
    $1 < /dev/null > /dev/null
    eval $(__brw_bind_BUFFER)
}

__dummy_widget() {
    let HISTNO++
    BUFFER="$(tail -n $HISTNO ~/.resh_history.json | head -n 1 | jq '.cmdLine' -r)"
    CURSOR=$CURSOR
}

__resh_readline_hook() {
    __RESH_READLINE_LINE=$READLINE_LINE
    __RESH_READLINE_POINT=$READLINE_POINT
    eval `__resh_recall`
}

# bindkey() {
# }


bind -x '"\[17~": __brw_widget_exec __dummy_widget'

# the bind chain
bind '"\C-x": "\[17~\[15~"'
