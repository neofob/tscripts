Block device scripts
====================
*Random scripts that deal with block device*
  * `cryptsetup.sh`: open a blockdev encrypted with cryptsetup
  * `dev_export.sh`: zerofree (optional), dd a blockdev and xz it to an output file
  * `dev_sync.sh`: [format], mount, sync a block device with a given directory
  * `zero_vm.sh`: umount block device(s), `zerofree` it
  * `zerofree_vdi.sh`: `zerofree` a virtual disk (vdi,qcow2...etc.)
  * `zram_sync.sh`: create a zram device, mount, rsync a given dir to it
