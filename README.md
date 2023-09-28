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

Note: `--net host` is used here because `-p 3260:3260` made the LUN to bind to the container network address.

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

Then find where it was mounted :  `journalctl --no-pager | grep "Attached SCSI"`
The core OS disk iamge : 
```
sudo blkid /dev/sdc*                                                                                                                                                         main  ✭ ✱
/dev/sdc: PTUUID="a1c653e9-8857-4eb1-b69b-6f53952a569d" PTTYPE="gpt"
/dev/sdc1: PARTLABEL="BIOS-BOOT" PARTUUID="6498509e-b163-4660-b067-04ea5db88b1d"
/dev/sdc2: SEC_TYPE="msdos" LABEL_FATBOOT="EFI-SYSTEM" LABEL="EFI-SYSTEM" UUID="3E45-2746" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="EFI-SYSTEM" PARTUUID="60f508bc-0dee-4355-b052-aae90650b550"
/dev/sdc3: LABEL="boot" UUID="78ec57df-7912-4cf1-b9c9-2a782bf6ea83" BLOCK_SIZE="1024" TYPE="ext4" PARTLABEL="boot" PARTUUID="3f1a5f26-36e1-4411-807c-b579d20d855d"
/dev/sdc4: LABEL="root" UUID="0f296b65-e139-4729-9890-c9312eb91bbd" BLOCK_SIZE="512" TYPE="xfs" PARTLABEL="root" PARTUUID="0a29aecb-1b5b-450b-9964-1760b3b72acf"
```

# Sources
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/configuring-an-iscsi-target_managing-storage-devices#installing-targetcli_configuring-an-iscsi-target
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_storage_devices/configuring-an-iscsi-initiator_managing-storage-devices

https://medium.com/oracledevs/kvm-iscsi-part-i-iscsi-boot-with-ipxe-f533f2666075
https://cleech.github.io/blog/2013/11/05/booting-virtual-machines-using-iscsi-part-2/
