#cloud-config
output:
  init:
      output: "> /var/log/cloud-init.out"
      error: "> /var/log/cloud-init.err"
  config: "tee -a /var/log/cloud-config.log"
  final:
      - ">> /var/log/cloud-final.out"
      - "/var/log/cloud-final.err"
disable_root: true 
system_info:
  default_user:
    name: ec2
disk_setup:
  /dev/xvdz:
    table_type: 'mbr'
    layout:
      - [100, 83]
    overwrite: True
fs_setup:
  - label: "data"
    filesystem: 'ext4'
    device: '/dev/xvdz'
    partition: 'auto'
mounts:
  - [ /dev/mapper/vg00-lv_opt, /opt/, auto, "defaults,noexec" ]
packages: 
  - dnsutils
  - curl
  - apt-transport-https
  - ca-certificates
  - software-properties-common
  - htop
  - vim
runcmd:
  - bash -c 'pvcreate -y /dev/xvdz1'
  - bash -c 'vgcreate -y vg00 /dev/xvdz1'
  - bash -c 'lvcreate -y -n lv_opt -L${volume_size}G vg00'
  - bash -c 'yes | mkfs.xfs -f /dev/mapper/vg00-lv_opt'
  - bash -c 'mount -a'