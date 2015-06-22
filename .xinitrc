#!/bin/sh

export LANG='ja_JP.UTF-8'
export GTK_IM_MODULE='uim'
export QZ_IM_MODULE='xim'
export XMODIFIERS='@im=uim'

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*;
    do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

[ -x /usr/bin/VBoxClient-all ] && /usr/bin/VBoxClient-all
[ -s ~/.xmodmap ] && xmodmap ~/.Xmodmap
[ -s ~/.xbindkeysrc ] && xbindkeys -f ~/.xbindkeysrc
[ -s ~/.Xresources ] && xrdb -merge ~/.Xresources

uim-xim &

exec startxfce4
