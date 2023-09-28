#!/bin/bash -x

podman run -d \
	--name targetclid \
	-v /lib/modules:/lib/modules \
	-v /var/run/dbus:/var/run/dbus \
  -v /sys/kernel/config:/sys/kernel/config \
	-v /dev/vdb:/dev/vdb \
	--privileged --cap-add=CAP_SYS_MODULE \
	-p 3260:3260 \
	targetcli
