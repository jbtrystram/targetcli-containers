# start VM hote 
j fcos
mv ../targetcli-containers/target.ign tmp/target.ign 
cosa run -i tmp/target.ign -m 4096 --add-disk 10G:serial=target --add-disk 10G:serial=var 
	


podman run --privileged --net=host -v /mnt/workdir-tmp/boot.ipxe:/mnt/boot.ipxe quay.io/coreos-assembler/coreos-assembler \
kola qemuexec --netboot /mnt/boot.ipxe --usernet-addr 10.0.3.0/24 --additional-nics 1

