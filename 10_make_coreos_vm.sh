#!/bin/bash
#set -ex

if [ "X$1" = "X--help" ]; then
    echo "\n${0} [type] [start num] [number of vms]\n"
    exit
fi


# Create a CoreOS VM, no disk, local coreos files.
TYPE=c2
START=0
NUM=1


VBOX=`which VirtualBox`
VBOXMANAGE=`which VBoxManage`
ISOFILE='ipxe.iso'


if [ "$1" ]; then
    TYPE=$1
fi

if [ "$2" ]; then
    START=$2
fi

if [ "$3" ]; then
    NUM=$3
fi


makevm () {
    #Do more argument error checking
    N=$1
    if [ $1 -lt 10 ]; then 
        N=0$1;
    fi

    # The name of your VM
    VM=${TYPE}_${N}

    VBOXINFO="${VBOXMANAGE} showvminfo ${VM}"

    #if VM exists
    if ${VBOXMANAGE} list vms | grep ${VM};  then
        ${VBOXMANAGE} unregistervm $VM --delete;
    fi


    #Create the VM
    ${VBOXMANAGE} createvm --name "${VM}" --ostype "Linux_64" --register
    ${VBOXMANAGE} modifyvm "${VM}" --memory 768
    ${VBOXMANAGE} modifyvm "${VM}" --vram 16

    ${VBOXMANAGE} modifyvm ${VM} --macaddress1 00000000${TYPE}${N} 
    ${VBOXMANAGE} modifyvm ${VM} --nic2 hostonly


    # Create IDE controller and attach DVD
    ${VBOXMANAGE} storagectl ${VM} --name "IDE controller" --add ide
    ${VBOXMANAGE} storageattach ${VM} --storagectl "IDE controller"  --port 0 --device 0 --type dvddrive --medium $ISOFILE



    ## Create the boot configuration (need machine UUID)
    UUID=`${VBOXINFO} |awk '/UUID/ {print $2}'|head -n 1`
    echo $UUID


    ## Start it up
    #${VBOX} --startvm "${VM}"
}
for N in $(seq $START $(expr $START + $NUM - 1));
do
    echo "\nMaking VM ${TYPE} ${N} of ${NUM}\n\n"
    makevm $N
done


