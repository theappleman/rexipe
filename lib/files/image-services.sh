#!/bin/bash

action=$1

case x"$action" in
xdisable)
	;;
xenable)
	;;
*)
	echo "Invalid action: $action" >&2
	exit 1
	;;
esac

for service in cloud-init cloudbackup-updater driveclient nova-agent rackspace-monitoring-agent newrelic-sysmond
do
	systemctl $action $service
done

# TODO:
# - remove root password
# - remove securetty
