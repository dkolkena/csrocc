#!/bin/bash
# Metering Log Monitor
# Written by Daniel Kolkena

version=1.0

newprev=$(hadoop fs -ls /meteringlogs/new/ | wc -l)
procprev=$(hadoop fs -ls /meteringlogs/processing/ | wc -l)
i=0 # Counter

while [[ $i -le 144 ]] # Will run a max of 144 iterations of 5 minutes, or 12 hours
do	
	new=$(hadoop fs -ls /meteringlogs/new/ | wc -l)
	proc=$(hadoop fs -ls /meteringlogs/processing/ | wc -l)

	clear
	printf "Metering Logs:\n"
	printf "New:\t\t%d\t(%+d)\n" "$new" "$((new-newprev))"
	printf "Processing:\t%d\t(%+d)\n\n" "$proc" "$((proc-procprev))"

	/opt/cloudcommon/flume/bin/flume shell -c localhost -e getnodestatus | grep -v ACTIVE
	hadoop dfsadmin -report | grep Datanodes 
	hadoop dfsadmin -report | grep Decommission
	
	printf "\nCurrent Mapreduce PIDs:\n"
	printf "================================================================================\n"
	ps -e -o pid= -o comm= -o args | grep mapreduce | grep -v grep | cut -c -80
	printf "================================================================================\n"

	printf "\nCurrent tail of map_reduce_output.log:\n"
	printf "================================================================================\n"
	tail -5 /opt/cloudcommon/metering/logs/map_reduce_output.log
	printf "================================================================================\n"
	echo "[Hit CTRL+C to end]"

	newprev=$new
	procprev=$proc
	i=$(( $i + 1 ))
	sleep 5m # Refreshes every 5 minutes.
done

echo "Exiting after 12 hours."
exit 0