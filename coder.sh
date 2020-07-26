if [ ! -d "/flag/hostname" ] 
then
  mkdir -p /flag/hostname
  apt update && apt install -y jq
  VMNAME=$(onegate vm show --json | jq -r '.VM | .NAME')
  echo $VMNAME > /etc/hostname
  echo "127.0.0.1 $VMNAME" >> /etc/hosts
fi

if [ ! -d "/flag/user" ] 
then
	adduser --disabled-password --gecos \"\" user
	echo "user    ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers
fi

if [ ! -d "/flag/vscode" ] 
then
	mkdir -p /flag/vscode
	cd /flag/vscode
	wget https://raw.githubusercontent.com/LEE-WAN/Opennuebula_Scripts/master/files/code-server_3.4.1_amd64.deb
	dpkg -i code-server_3.4.1_amd64.deb
	mkdir -p /home/user/.config/code-server
	echo "$(cat <<-EOF
bind-addr: 0.0.0.0:10000
auth: none
cert: false
	EOF
	)" > /home/user/.config/code-server/config.yaml
	echo "$(cat <<-EOF
[Unit]
Description=Coder
[Service]
Type=simple
PIDFile=/run/coder.pid
ExecStart=/usr/bin/code-server
User=user
Group=user
WorkingDirectory=/home/user
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
	EOF
	)" > /etc/systemd/system/coder.service
	systemctl enable coder.service
	reboot
fi
