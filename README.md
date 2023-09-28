# Create SCSI LUN disks in container

Use targetcli in containers.
This **MUST** be run as root. 

## Build the image
```bash
# podman build -t targetcli -f Dockerfile .
```

## Volumes
The config in `saveconfig.json` expose `/dev/vdb` as a backstore. 
My use case here is to mount a CoreOS raw image disk as a virtual disk in a QEMU VM that act as the iSCSI server.

## Run the container and exec to create the disks
```bash
# podman run -d \
	--name targetclid \
	-v /lib/modules:/lib/modules \
	-v /var/run/dbus:/var/run/dbus \
  -v /sys/kernel/config:/sys/kernel/config \
	-v /dev/vdb:/dev/vdb \
	--privileged --cap-add=CAP_SYS_MODULE \
	--net host \
	targetcli
```

## Mounting the iSCSI target

The target is `iqn.2023-09.centos.vm:coreos`. No auth is required. 
So on the initator, to mount the volume
Discover : 
```
# iscsiadm -m discovery -t st -p 192.168.122.2
10.88.0.2:3260,1 iqn.2023-09.centos.vm:coreos
```

Mount :
```
sudo  iscsiadm -m node -T iqn.2023-09.centos.vm:coreos -l
Logging in to [iface: default, target: iqn.2023-09.centos.vm:coreos, portal: 192.168.122.2,3260]
Login to [iface: default, target: iqn.2023-09.centos.vm:coreos, portal: 192.168.122.2,3260] successful.
```

# Sources
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/configuring-an-iscsi-target_managing-storage-devices#installing-targetcli_configuring-an-iscsi-target
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/configuring-an-iscsi-initiator_managing-storage-devices

https://medium.com/oracledevs/kvm-iscsi-part-i-iscsi-boot-with-ipxe-f533f2666075
https://cleech.github.io/blog/2013/11/05/booting-virtual-machines-using-iscsi-part-2/
