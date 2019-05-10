# mount nfs server
mount -t nfs 10.32.97.3:/iso coeNfs

# mount the iso file
sudo mount -t iso9660 -o loop coeNfs/hailstorm/iso/rhel-server-7.5-x86_64-dvd.iso  isoMount

#Create dir for content of new iso:
mkdir newIso

# copy all stuff from existing ISO (kindof extracting all files from the ISO image):
cp -avRf isoMount/* newIso

# Copy Kickstart file:
# (This is used automatically by Kickstart if the disk
# is labeled OEMDRV)
cp ~/storm3rhev/storm3_kickstart.cfg  newIso/ks.cfg

# TODO: Provide hailstorm pub key for installation into /root/.ssh/authorized_keys



# All files are readonly because they were copied from
# a read only image (CD ROM). We need to change the following
# files:
chmod a+w newIso/isolinux/isolinux.cfg
chmod a+w newIso/isolinux/isolinux.bin

# Edit boot menu to boot from disk labeled OEMDRV
vi newIso/isolinux/isolinux.cfg

# Replace “inst.stage2=hd:LABEL=RHEL-7.2\x20Server.x86_64” with “inst.stage2=hd:LABEL=OEMDRV”

# Create new ISO DISK Labeld OEMDRV
cd newIso
genisoimage -U -r -v -T -J -joliet-long -V OEMDRV -volset OEMDR -A OEMDRV -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -o ../new_rhel7.iso .

genisoimage -U -r -v -T -J -joliet-long -V OEMDRV -volset OEMDR -A OEMDRV -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -o ../new_rhel7.iso .
# Create MD5 sum
implantisomd5 ../new_rhel7.iso

# Check volumne name to be OEMDRV:
blkid ../new_rhel7.iso
checkisomd5 ../new_rhel7.iso

# Copy new iso file image back to nfs server:
cp new_rhel7.iso coeNfs/hailstorm/iso/rhel-server-7.6-storm3.iso


##
# TODO: Copy SSH Key for root authorized_key!
