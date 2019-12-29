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
    local revert=0
    local keymap=""
    if [ "${1-}" = "-r" ] || [ "${1-}" = "--revert" ]; then
        revert=1
        shift
    fi
    if [ "${1-}" = "-m" ] || [ "${1-}" = "-M" ]; then
        shift
        keymap=${1-}
        shift
    fi
    if [ "${1-}" = "-r" ] || [ "${1-}" = "--revert" ]; then
        revert=1
        shift
    fi
    if [ "$#" -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This is bindfunc - common wrapper for bash bind and zsh binkey" >&2
        echo "USAGE: bindfunc [OPTIONS] key_sequence widget_name [OPTIONS_FOR_bind_AND_bindkey]" >&2
        echo "" >&2
        echo "OPTIONS:" >&2
        echo "    -r|--revert" >&2
        echo "        Set '_bindfunc_revert' variable to a command that can be evaluated to revert the effect of this bindfunc call." >&2
        echo "    -m KEYMAP|-M KEYMAP" >&2
        echo "        Specify keymap to use when binding. Accepts both zsh and bash keymap keywords." >&2
        echo "    -h|--help" >&2
        echo "        Show this help." >&2
        return 1
    fi

    local keyseq=$1
    local func=$2
    shift 2

    # translate keymaps
    # zsh
    # command     emacs       isearch     listscroll  main        menuselect  .safe       vicmd       viins       viopp       visual
    # bash
    # emacs           emacs-ctlx      emacs-meta      emacs-standard  vi              vi-command      vi-insert       vi-move
    local zsh_keymap
    local bash_keymap
    if [ "$keymap" != "" ]; then
        case "$keymap" in
            vicmd|vi-command)
                zsh_keymap=vicmd
                bash_keymap=vi-command
            ;;
            viins|vi-insert)
                zsh_keymap=viins
                bash_keymap=vi-insert
            ;;
            # TODO: add all modes
            *)
                # TODO: show full help
                echo "ERROR: Unknown keymap in -m/-M option - please provide zsh or bash keymaps"
                echo "Run bindfunc -h|--help to see usage"
                return 1
            ;;
        esac
    fi

    if [ -n "${ZSH_VERSION-}" ]; then
        # zsh
        if [ "$revert" -eq 1 ]; then
            local original_bind
            original_bind=$(bindkey "$keyseq")
            if echo "${#original_bind}" | grep 'undefined-key$' -q; then
                # clear binding
                # shellcheck disable=SC2034
                _bindfunc_revert="bindkey -r $keyseq"
            else
                # revert binding
                # shellcheck disable=SC2034
                _bindfunc_revert="bindkey $original_bind"
            fi
        fi
        zle -N "$func" "$func"
        if [ "$keymap" = "" ]; then
            bindkey "$keyseq" "$func" "$@"
        else
            bindkey -M $zsh_keymap "$keyseq" "$func" "$@"
        fi
    elif [ -n "${BASH_VERSION-}" ]; then
        # bash
        if [ "$revert" -eq 1 ]; then
            local original_bind
            # NOTE: bash bind list will sometimes contain inactive bindings and/or multiple bindings for the same key sequence
            # I've made a SO post about this: https://stackoverflow.com/questions/59292248/why-does-bind-x-show-inactive-bindings
            # we just take the first result and hope for the best
            original_bind=$( (bind -s; bind -p; bind -X) | grep -F "\"$keyseq\":" | head -n 1 )
            if [ "${#original_bind}" -eq 0 ]; then
                # clear binding
                # shellcheck disable=SC2034
                _bindfunc_revert="bind -r \"$keyseq\""
            else
                # revert binding
                # shellcheck disable=SC2034
                _bindfunc_revert="bind '$original_bind'"
            fi
        fi

        # bind -r "$keyseq"
        if [ "$keymap" = "" ]; then
            bind -x "\"$keyseq\": $func" "$@"
        else
            bind -m $bash_keymap -x "\"$keyseq\": $func" "$@"
        fi
    else
        echo "bindfunc ERROR: Unrecognized shell" >&2
        return 1
    fi
}
