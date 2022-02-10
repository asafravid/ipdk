#!/bin/bash
#Copyright (C) 2021 Intel Corporation
#SPDX-License-Identifier: Apache-2.0

#...Setting Hugepages...#
mkdir -p /mnt/huge
if [ "$(mount | grep hugetlbfs)" == "" ]
then
        mount -t hugetlbfs nodev /mnt/huge
fi

if [ -e /etc/fstab ]; then
        if [ "$(grep huge < /etc/fstab)" == "" ]
        then
                echo -e "nodev /mnt/huge hugetlbfs\n" >> /etc/fstab
        fi
fi

if [ "$(grep nr_hugepages < /etc/sysctl.conf)" == "" ]
then
        echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf
        #sysctl -p /etc/sysctl.conf
fi

# Get pagesize in MegaBytes:
pagesizeM=$(cat /proc/mounts | grep hugetlbfs)
# Remove Prefix of = from: hugetlbfs /dev/hugepages hugetlbfs rw,relatime,pagesize=512M 0 0
pagesizeM=${pagesizeM#*=}
# Remove Suffix of M from: hugetlbfs /dev/hugepages hugetlbfs rw,relatime,pagesize=512M 0 0
pagesizeM=${pagesizeM%M*}
echo "pagesizeM is ${pagesizeM}"

# 4 pages of 512M is equal to 1024 pages of 2M (i.e. 2GB total)
if [ "$pagesizeM" == "512" ]; then
        echo "Using 4 pages of 512M on each node"
        num_pages="4"
        pagesizeKB="524288"
        #echo 4 > /sys/devices/system/node/node0/hugepages/hugepages-524288kB/nr_hugepages
else
        echo "Using 1024 pages of 2M on each node"
        num_pages="1024"
        pagesizeKB="2048"
fi

#
# Check if the kernel/mm version of hugepages exists, and set hugepages if so.
#
if [ -d /sys/kernel/mm/hugepages/hugepages-${pagesizeKB}kB ] ; then
        echo "setting ${num_pages} to /sys/kernel/mm/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages"
        echo ${num_pages} | tee /sys/kernel/mm/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages
fi

#
# Check if the node version of hugepages exists, and set hugepages if so.
#
if [ -d /sys/devices/system/node/node0/hugepages/hugepages-${pagesizeKB}kB ] ; then
        echo "setting ${num_pages} to /sys/devices/system/node/node0/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages"
        echo ${num_pages} | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages
fi
if [ -d /sys/devices/system/node/node1/hugepages/hugepages-${pagesizeKB}kB ] ; then
        echo "setting ${num_pages} to /sys/devices/system/node/node1/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages"
        echo ${num_pages} | sudo tee /sys/devices/system/node/node1/hugepages/hugepages-${pagesizeKB}kB/nr_hugepages
fi
