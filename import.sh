#!/bin/bash
set -x

# Automatically find the .ova file in the current directory
OVA_TEMPLATE=$(ls *.ova 2>/dev/null | head -n 1)

# Check if an .ova file was found
if [ -z "$OVA_TEMPLATE" ]; then
    echo "Error: No .ova file found in the current directory."
    exit 1
fi

EXTRACT_PATH="$(pwd)/temp"

echo "Extracting OVA file to $EXTRACT_PATH..."
mkdir -p "$EXTRACT_PATH"
echo "Using OVA file: $OVA_TEMPLATE"
tar -xvf "${OVA_TEMPLATE}" -C "$EXTRACT_PATH"

# Use the OVA filename to define the VM name before deleting the OVA
VM_NAME=$(basename "$OVA_TEMPLATE" | cut -d'.' -f1)

# Delete the .ova file
rm "${OVA_TEMPLATE}"

# Continue with the rest of your script...
VM_ID=$(pvesh get /cluster/nextid)
VM_RAM=2048
VM_SOCK=1
VM_CORES=1
VM_AUTO_START=0
VM_KVM=1
VM_BRIDGE="vmbr10"

# Create the VM with default settings
qm create ${VM_ID} --autostart ${VM_AUTO_START} --cores ${VM_CORES} --kvm ${VM_KVM} --memory ${VM_RAM} --name ${VM_NAME} --sockets ${VM_SOCK} --scsihw virtio-scsi-pci --net0 virtio,bridge=${VM_BRIDGE},firewall=0

echo -e "\nThe following disk will be converted: "
cd $EXTRACT_PATH
ls -1 *.vmdk *.vhd *.vdi

echo -e "\nConverting and importing disks..."
disk_nb=0
for disk in *.vmdk *.vhd *.vdi; do
    CONTROLLER="scsi"
    qemu-img convert -f vmdk -O qcow2 "${disk}" "vm-${VM_ID}-disk-${disk_nb}.qcow2"
    qm importdisk ${VM_ID} "vm-${VM_ID}-disk-${disk_nb}.qcow2" local-lvm -format qcow2
    echo "Attach disk number ${disk_nb} to the VM..."
    qm set ${VM_ID} --${CONTROLLER}${disk_nb} local-lvm:vm-${VM_ID}-disk-${disk_nb}
    disk_nb=$((disk_nb+1))
done

cd ..
rm -rf $EXTRACT_PATH

echo "VM ${VM_ID} setup complete."
