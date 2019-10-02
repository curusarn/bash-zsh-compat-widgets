# primitive compat wrapper - lets you use simple zsh widgets in bash and (afaik) all bash "widgets" in zsh
__bindfunc_compat_wrapper() {
    local widget=$1
    shift
    if [ -n "$ZSH_VERSION" ]; then
        # zsh
        # populate bash variables
        local READLINE_LINE=$BUFFER
        local READLINE_POINT=$CURSOR
        # save current state
        local PREV_BUFFER=$BUFFER
        local PREV_CURSOR=$CURSOR
        # run widget
        $widget "$@"
        # check if the widget changed/used zsh variables
        #   if not use bash variables
        [ "$PREV_BUFFER" = "$BUFFER" ] && BUFFER=$READLINE_LINE
        [ "$PREV_CURSOR" = "$CURSOR" ] && CURSOR=$READLINE_POINT
    elif [ -n "$BASH_VERSION" ]; then
        # bash
        # populate zsh variables
        local BUFFER=$READLINE_LINE
        local CURSOR=$READLINE_POINT
        # save current state
        local PREV_READLINE_LINE=$READLINE_LINE
        local PREV_READLINE_POINT=$READLINE_POINT
        # run widget
        $widget "$@"
        # check if the widget changed/used bash variables
        #   if not use zsh variables
        [ "$PREV_READLINE_LINE" = "$READLINE_LINE" ] && READLINE_LINE=$BUFFER
        [ "$PREV_READLINE_POINT" = "$READLINE_POINT" ] && READLINE_POINT=$CURSOR
    else
        echo "bindfunc ERROR: unrecognized shell"
    fi
}

# unified way to bind functions as zsh zle widgets and bash readline "widgets"
bindfunc() {
    if [ "$#" -lt 2 ]; then
        echo "This is bindfunc - common wrapper for bash bind and zsh binkey"
        echo "USAGE: bindfunc key_sequence widget_name [OPTIONS]"
    fi

    local keyseq=$1
    local func=$2
    shift 2

    if [ -n "$ZSH_VERSION" ]; then
        # zsh
        zle -N "$func" "$func"
        bindkey "$keyseq" "$func" "$@"
    elif [ -n "$BASH_VERSION" ]; then
        # bash
        bind -x "\"$keyseq\": $func" "$@"
    else
        echo "bindfunc ERROR: unrecognized shell"
    fi
}
