#!/bin/sh
# /etc/init.d/subnode
# starts up wlan0 interface ( and at some point, batman-adv )
# starts up hostapd => broadcasting wireless network HOT PROBS
# starts up node app

#TODO move app to /usr/bin/
DAEMON_PATH="/home/pi/www"

DAEMON=sudo
#DAEMONOPTS="nodemon --watch /home/pi/Dev/fabServ /home/pi/Dev/fabServ/app.js"
DAEMONOPTS="NODE_ENV=production nodemon subnode.js"

NAME=subnode
DESC="Runs /home/pi/www/subnode.js in production mode with nodemon"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

	case "$1" in
		start)
			echo "Starting $NAME and hostapd!"
			#sudo insmod /lib/modules/3.2.27+/kernel/net/batman-adv/batman-adv.ko
			#sudo /sbin/ifdown wlan0
			#sudo batctl if add wlan0
			#sudo ifconfig bat0 up
			#sudo /sbin/ifup wlan0
			#sudo /etc/init.d/dnsmasq restart
			#sudo /etc/init.d/hostapd restart
			sudo hostapd -B /etc/hostapd/hostapd.conf
			cd $DAEMON_PATH
			PID=`$DAEMON $DAEMONOPTS > /dev/null 2>&1 & echo $!`
			#echo "Saving PID" $PID " to " $PIDFILE
				if [ -z $PID ]; then
					printf "%s\n" "Fail"
				else
					echo $PID > $PIDFILE
					printf "%s\n" "Ok"
				fi
			;;
		status)
			printf "%-50s" "Checking $NAME..."
			if [ -f $PIDFILE ]; then
				PID=`cat $PIDFILE`
				if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
					printf "%s\n" "Process dead but pidfile exists"
				else
					echo "Running"
				fi
			else
				printf "%s\n" "Service not running"
			fi
		;;
		stop)
			printf "%-50s" "Shutting down $NAME…"
				PID=`cat $PIDFILE`
				cd $DAEMON_PATH
			if [ -f $PIDFILE ]; then
				kill -HUP $PID
				printf "%s\n" "Ok"
				rm -f $PIDFILE
			else
				printf "%s\n" "pidfile not found"
			fi
		;;

		restart)
			$0 stop
			$0 start
		;;

*)
		echo "Usage: $0 {status|start|stop|restart}"
		exit 1
esac