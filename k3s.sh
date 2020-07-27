if [ ! -d "/flag/hostname" ] 
then
  mkdir -p /flag/hostname
  apt update && apt install -y jq
  VMNAME=$(onegate vm show --json | jq -r '.VM | .NAME' | sed -r 's/[_]+/-/g' | sed -r 's/[()]+//g')
  echo $VMNAME > /etc/hostname
  echo "127.0.0.1 $VMNAME" >> /etc/hosts
  reboot
fi

if [ ! -d "/flag/k3s" ] 
then
  mkdir -p /flag/k3s
  curl -sfL https://get.k3s.io | sh -
  echo "
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s \
  server --disable servicelb\
  " > /etc/systemd/system/k3s.service
  systemctl daemon-reload
  reboot
fi