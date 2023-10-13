# FCOS target virtual machine

The setup here is a FCOS WM that exposes a target through a privileged container.

## Prerequisites

A raw image disk of FCOS can be created with the coreos-assembler : `cosa fetch && cosa build && cosa buildextend-metal`

## Virtual machine creation

First, generate the ignition config:
```
podman run --rm -v ./:/srv:z quay.io/coreos/butane:release --pretty --strict -d /srv /srv/target.bu > target.ign
```

Launch a new virtual machine:
```
# This is the raw disk file that will be exposed through the iSCSI target
# Note that this must be the directory containing the actual raw file
# The expected file name is `fcos.raw`
RAW_DISK=/path/to/fcos.raw/
FCOS_IMAGE=/path/to/coreos.qcow2
IGNITION_FILE=path/to/target.ign

# virt-install --connect="qemu:///system" --name="fcos-target" --vcpus=2 --memory=2048                      \
    --os-variant="fedora-coreos-stable" --import --graphics=none                                            \
    --disk="size=10,backing_store=${FCOS_IMAGE}"                                                            \
    --network bridge=virbr0 --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_FILE}"     \
    --filesystem=${RAW_DISK},var-shared,driver.type=virtiofs                                                \
    --memorybacking=source.type=memfd,access.mode=shared
```

Here we use the virtioFS filesystem to mount the coreOS raw disk image into the VM. 

# TODO / ideas

- [] iPXE boot script
- [] add a DHCP service as well (to help iPXE boot)

# Resources

https://dustymabe.com/2023/09/08/using-virtiofs-with-libvirt/virt-install/
