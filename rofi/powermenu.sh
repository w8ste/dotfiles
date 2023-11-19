#! /usr/bin/bash
#
chosen=$(printf "󰐥 Power Off\n Restart\n Log out\n󰤄 Suspend" | rofi -dmenu -i -l 4)
case "$chosen" in 
	"󰐥 Power Off") shutdown now;;
	" Restart") reboot ;;
    " Log out") i3-msg exit ;;
    "󰤄 Suspend") systemctl suspend ;;
	*) exit 1 ;;
esac
