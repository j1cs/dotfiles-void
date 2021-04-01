#!/bin/sh

# Strict script
#set -e causes the shell to exit when an unguarded statement evaluates to a false value (i have to disable because of cap lock function)
set -u
#set -x

hdd(){
	hdd="`df -h | awk 'NR==4{print $3, $5}'`"
	echo -e "+@fg=7;+@fg=0; $hdd"
}


mem() {
	mem="`free | awk '/Mem/ {printf "%d MiB / %d MiB : %d%\n", $3 / 1024.0, $2 / 1024.0,  $3/$2 *100}'`"
	printf "+@fg=7;+@fg=0; %d%%" `echo "$mem"`
}

bri(){
	brightness="`ligh`"
	printf " %s%%" `echo "$brightness"`
}

cpu() {
	read cpu a b c previdle rest < /proc/stat
  	prevtotal=$((a+b+c+previdle))
  	sleep 0.5
  	read cpu a b c idle rest < /proc/stat

	total=$((a+b+c+idle))
 	cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
	printf "+@fg=7;+@fg=0; %s%%" `echo "$cpu"`

}

vol(){
	# todo save into a file
	vol="`pacmd list-sinks | awk '/\tvolume:/ { print $5 }'  | tail -n1 | cut -d '%' -f 1`"
	if [ $vol -gt 70 ]; then
		icon=""
	elif [ $vol -eq 0 ]; then
		icon=""
	elif [ $vol -lt 30 ]; then
		icon=""
	else
		icon=""
	fi
	printf "+@fg=7;$icon+@fg=0; %s%%" `echo "$vol"`
}

dte() {
	dte=" `date +"%Y-%m-%d"`  `date +"%H:%M"`"
	echo -e "$dte"
}

bat() {
	capacity=97
	current=`/sys/class/power_supply/BAT$2/capacity`
	status=`/sys/class/power_supply/BAT$2/status`

	if [ $status = "Charging" ] && [ $current -eq $capacity ]; then
		printf "+@fg=5; +@fg=0;%s%%" `echo "$capacity" | bc`
	fi
	if [ $status -eq 0 ] && [ $current -ne $capacity ]; then
		if [ $current -eq 100 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 60 ]; then
			icon="+@fg=5;+@fg=0;"
		elif [ $current -gt 50 ]; then
			icon="+@fg=4;+@fg=0;"
		elif [ $current -gt 25 ]; then
			icon="+@fg=4;+@fg=0;"
		else
			icon="+@fg=6;+@fg=0;"
		fi
		printf "$icon %s%%" `echo "$current" | bc`
	fi

	if [ $status = 1 ] && [ $current -ne $capacity ]; then
		if [ $1 -eq 4 ]; then
			icon=""
		elif [ $1 -eq 3 ]; then
			icon=""
		elif [ $1 -eq 2 ]; then
			icon=""
		elif [ $1 -eq 1 ]; then
			icon=""
		else
			icon=""
		fi
		printf "+@fg=4;$icon+@fg=0; %s%%" `echo "$current" | bc`
	fi

}

layout() {
	lay_result="`xset -q | grep -i "led mask" | grep -o "....1..."`"
	lay="`[ -z $lay_result ] && echo "latam" || echo "es"`"
	echo -e " $lay"
}

lock() {
	cap_result=`xset q | grep -q 'Caps Lock: *on'`
	cap="`[ $? == 0 ] && echo "" || echo ""`"
	num_result=`xset q | grep -q 'Num Lock: *on'`
	num="`[ $? == 0 ] && echo "" || echo ""`"
	echo -e "+@fg=7;$cap+@fg=0; a +@fg=7;$num+@fg=0; 1"
}

SLEEP_SEC=0.1
I=0
BAT_ITER=4
while :; do
	if [ $I -gt $BAT_ITER ]; then
		I=0
	fi
	echo "`cpu`  `mem`  `hdd`  `vol`  `bri`  `bat $I 1` `bat $I 2` `layout`  `lock`  `dte`"
	I=`expr $I + 1`
	sleep $SLEEP_SEC
done
