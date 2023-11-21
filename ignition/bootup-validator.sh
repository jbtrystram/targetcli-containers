#!/bin/bash

## TODO : 
## Create an ignition config passed on the nested VM 
# that writes on a virtio-serial device when booted.
journalctl --unit iscsi-boot  -g '.*OK.*multi-user\.target' -o cat -q