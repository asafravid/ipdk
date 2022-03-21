./ipdk execute --- gnmi-cli set "device:virtual-device,name:net_vhost0,host:host1,device-type:VIRTIO_NET,queues:1,socket-path:/tmp/intf/vhost-user-0,port-type:LINK"
./ipdk execute --- gnmi-cli set "device:virtual-device,name:net_vhost1,host:host1,device-type:VIRTIO_NET,queues:1,socket-path:/tmp/intf/vhost-user-1,port-type:LINK"

export OUTPUT_DIR=/root/examples/simple_l3
./ipdk execute --- p4c --arch psa --target dpdk --output $OUTPUT_DIR/pipe --p4runtime-files $OUTPUT_DIR/p4Info.txt --bf-rt-schema $OUTPUT_DIR/bf-rt.json --context $OUTPUT_DIR/pipe/context.json $OUTPUT_DIR/simple_l3.p4
./ipdk execute /root/examples/simple_l3 --- ovs_pipeline_builder --p4c_conf_file=simple_l3.conf --bf_pipeline_config_binary_file=simple_l3.pb.bin

./ipdk execute --- ovs-p4ctl set-pipe br0 /root/examples/simple_l3/simple_l3.pb.bin /root/examples/simple_l3/p4Info.txt

./ipdk execute --- ovs-p4ctl add-entry br0 ingress.ipv4_host "hdr.ipv4.dst_addr=192.168.1.88,action=ingress.send(1)"
./ipdk execute --- ovs-p4ctl add-entry br0 ingress.ipv4_host "hdr.ipv4.dst_addr=192.168.1.87,action=ingress.send(0)"
