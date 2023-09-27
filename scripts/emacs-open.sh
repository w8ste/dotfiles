#!/bin/bash
if pgrep emacs ; then
   emacsclient -a '' -c "$@" &
else
    emacs &
fi
