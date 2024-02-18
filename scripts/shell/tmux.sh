#!/usr/bin/zsh

if [ -x "$(command -v tmux)" ] && \
   [ -n "${DISPLAY}" ] && \
   [ -z "${TMUX}" ]; then # && \
   # [ "${TERM_PROGRAM}" != "vscode" ]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi
