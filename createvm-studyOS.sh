#!/usr/bin/env bash

export VMName="studyOS"
export ISOFilePath="~/Downloads/trisquel-netinst_10.0_amd64.iso"
export VM_NET="default"
export VM_OS="ubuntu20.04"
export VM_IMG="/data/libvirt/images/${VMName}.qcow2"
export CPUCount=1
export VM_DISKSIZE=50
export MemorySize=2048


if [ ! -f "${ISOFilePath}" ]; then
  wget "${url}" -P "${ISOFilePath}"
fi


echo "Creating ${VMName} disk at $DiskDir. Its size is $DiskSize."
if [ ! -d "$DiskDir" ]; then
    mkdir -p "$DiskDir"
fi


if which virtualbox; then
  VMName="studyOS"
  DiskDir="/mnt/$(whoami)/VMs/${VMName}"
  DiskSize=$((1024*50))
  MemorySize=$((1024*2))
  VRamSize=128
  CPUCount=1
  OSTypeID="Ubuntu_64"
  NetworkInterface="wlx503eaa732ee3"
  url="http://cdimage.trisquel.info/trisquel-images/trisquel-netinst_10.0_amd64.iso"
  ISOFilePath="~/Downloads/trisquel-netinst_10.0_amd64.iso"

  #VBoxManage list vms
  echo "Creating disk..."
  VBoxManage createhd --filename "$DiskDir/${VMName}.vdi" --size $DiskSize 

  echo "Creating VM..."
  VBoxManage createvm --name ${VMName} --ostype "$OSTypeID" --register

  echo "Adding the created disk to the VM..."
  VBoxManage storagectl ${VMName} --name "SATA Controller" --add sata --portcount 1 --controller IntelAHCI
  VBoxManage storageattach ${VMName} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DiskDir/${VMName}.vdi"

  VBoxManage storagectl ${VMName} --name "IDE Controller" --add ide
  VBoxManage storageattach ${VMName} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISOFilePath"

  echo "Setting memory..."
  VBoxManage modifyvm ${VMName} --memory $MemorySize --vram $VRamSize --cpus $CPUCount

  echo "Setting boot sequence..."
  VBoxManage modifyvm ${VMName} --boot1 dvd --boot2 disk --boot3 none --boot4 none

  echo "Setting network..."
  VBoxManage modifyvm ${VMName} --nic1 bridged --bridgeadapter1 $NetworkInterface

  VBoxManage modifyvm ${VMName} --nested-hw-virt on
  echo "VM Creation completed."
else
  # Assume KVM virt-install
  if which virt-install; then
    sudo virt-install --name ${VMName} \
--memory ${MemorySize} \
--vcpus ${CPUCount} \
--os-variant=${VM_OS} \
--virt-type=kvm \
--cdrom=${ISOFilePath} \
--network network=${VM_NET},model=virtio \
--graphics vnc \
--disk path=${VM_IMG},size=${VM_DISKSIZE},bus=virtio,format=qcow2
  fi
fi
