FCOS target VM : 

```
podman run --rm -v ./:/srv:z quay.io/coreos/butane:release --pretty --strict -d /srv /srv/target.bu > target.ign

 virt-install --connect="qemu:///system" --name="fcos-target" --vcpus=2 --memory=2048 \      
        --os-variant="fedora-coreos-stable" --import --graphics=none \
        --disk="size=10,backing_store=/path/to/image.qcow2" \
        --network bridge=virbr0 --qemu-commandline=-fw_cfg name=opt/com.coreos/config,file=/path/to/target.ign \
        --disk /path/to/fcos.raw
``` 

An important bit is the last `disk` argument: it's the actual block device that will expose as the iSCSI target. 

TODO: add a DHCP service as well (to help iPXE boot)
