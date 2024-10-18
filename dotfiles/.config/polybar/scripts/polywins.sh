#!/bin/sh
# POLYWINS

# SETTINGS {{{ ---

active_text_color="#CCCCFF"
active_bg=
active_underline="#CCCCFF"

inactive_text_color="#BDB5D5"
inactive_bg=
inactive_underline=

separator=" "
show="icon" # options: window_title, window_class, window_classname, icon
forbidden_classes="Polybar Conky Gmrun"
empty_desktop_message="Desktop"

char_limit=20
max_windows=15
char_case="normal" # normal, upper, lower
add_spaces="true"
resize_increment=16
wm_border_width=1 # setting this might be required for accurate resize position

# --- }}}

# Helper Functions {{{ ---

format_window_name() {
    local wid="$1" title="$2"
    if [ "$add_spaces" = "true" ]; then
        title=" $title "
    fi

    if [ "$wid" = "$active_wid" ]; then
        printf "%s" "${active_left}${title}${active_right}"
    else
        printf "%s" "${inactive_left}${title}${inactive_right}"
    fi
}

handle_clicks() {
    local wid="$1"
    printf "%s" "%{A1:$on_click raise_or_minimize $wid:}"
    printf "%s" "%{A2:$on_click close $wid:}"
    printf "%s" "%{A3:$on_click slop_resize $wid:}"
    printf "%s" "%{A4:$on_click increment_size $wid:}"
    printf "%s" "%{A5:$on_click decrement_size $wid:}"
}

# --- }}}

main() {
    if [ -z "$2" ]; then
        xprop -root -spy _NET_CLIENT_LIST _NET_ACTIVE_WINDOW |
        while IFS= read -r _; do
            generate_window_list
        done
    else
        "$@"
    fi
}

# ON-CLICK FUNCTIONS {{{ ---

raise_or_minimize() {
    if [ "$(get_active_wid)" = "$1" ]; then
        bspc node "$1" -g hidden=on
    else
        bspc node "$1" -g hidden=off -f
    fi
}

close() {
    wmctrl -ic "$1"
}

slop_resize() {
    wmctrl -ia "$1"
    wmctrl -ir "$1" -e "$(slop -f 0,%x,%y,%w,%h)"
}

increment_size() {
    resize_window "$1" "$resize_increment"
}

decrement_size() {
    resize_window "$1" "-$resize_increment"
}

resize_window() {
    local wid="$1" increment="$2"
    while IFS="[ .]" read -r wid ws wx wy ww wh _; do
        test "$wid" != "$1" && continue
        x=$((wx - wm_border_width * 2 - increment / 2))
        y=$((wy - wm_border_width * 2 - increment / 2))
        w=$((ww + increment))
        h=$((wh + increment))
    done <<-EOF
	$(wmctrl -lG)
	EOF
    wmctrl -ir "$1" -e "0,$x,$y,$w,$h"
}

# --- }}}

# WINDOW LIST SETUP {{{ ---

# Setting up colors and styles
active_left="%{F$active_text_color}"
active_right="%{F-}"
inactive_left="%{F$inactive_text_color}"
inactive_right="%{F-}"
separator="%{F$inactive_text_color}$separator%{F-}"

if [ -n "$active_underline" ]; then
    active_left="${active_left}%{+u}%{u$active_underline}"
    active_right="%{-u}${active_right}"
fi

if [ -n "$inactive_underline" ]; then
    inactive_left="${inactive_left}%{+u}%{u$inactive_underline}"
    inactive_right="%{-u}${inactive_right}"
fi

get_active_wid() {
    active_wid=$(xprop -root _NET_ACTIVE_WINDOW)
    active_wid="${active_wid#*\# }"
    active_wid="${active_wid%,*}"
    while [ ${#active_wid} -lt 10 ]; do
        active_wid="0x0${active_wid#*x}"
    done
    echo "$active_wid"
}

get_active_workspace() {
    wmctrl -d |
    while IFS="[ .]" read -r number active_status _; do
        test "$active_status" = "*" && echo "$number" && break
    done
}

generate_window_list() {
    active_workspace=$(get_active_workspace)
    active_wid=$(get_active_wid)
    window_count=0
    on_click="$0"

    while IFS="[ .\.]" read -r wid ws cname cls host title; do
        # Skip if not on active workspace or forbidden class
        if [ "$ws" != "$active_workspace" ] && [ "$ws" != "-1" ]; then continue; fi
        case "$forbidden_classes" in *"$cls"*) continue; esac

        if [ "$window_count" -ge "$max_windows" ]; then
            window_count=$((window_count + 1))
            continue
        fi

        # Determine window name based on configuration
        case "$show" in
            "window_class") w_name="$cls" ;;
            "window_classname") w_name="$cname" ;;
            "window_title") w_name="$title" ;;
            "icon")
                case "$cls" in
                    St) w_name='' ;;
                    Chromium-browser) w_name='' ;;
                    TelegramDesktop) w_name=' ' ;;
                    Pcmanfm) w_name='' ;;
                    SimpleScreenRecorder) w_name='' ;;
                    Blue-recorder) w_name='' ;;
                    Firefox) w_name='' ;;
                    figma-linux) w_name='' ;;
                    *) w_name="$cls" ;;
                esac
                ;;
        esac

        # Apply character case and truncation
        case "$char_case" in
            "lower") w_name=$(echo "$w_name" | tr '[:upper:]' '[:lower:]') ;;
            "upper") w_name=$(echo "$w_name" | tr '[:lower:]' '[:upper:]') ;;
        esac
        [ "${#w_name}" -gt "$char_limit" ] && w_name="$(echo "$w_name" | cut -c1-$((char_limit - 1)))…"

        # Format window name
        formatted_name=$(format_window_name "$wid" "$w_name")

        # Add separator and on-click actions
        if [ "$window_count" != 0 ]; then printf "%s" "$separator"; fi
        handle_clicks "$wid"
        printf "%s" "$formatted_name"

        window_count=$((window_count + 1))
    done <<-EOF
	$(wmctrl -lx)
	EOF

    # Print number of hidden windows if max_windows exceeded
    [ "$window_count" -gt "$max_windows" ] && printf "%s" "+$((window_count - max_windows))"

    # Print empty desktop message if no windows are open
    [ "$window_count" = 0 ] && printf "%s" "$empty_desktop_message"

    # Print newline
    echo ""
}

# --- }}}

main "$@"
