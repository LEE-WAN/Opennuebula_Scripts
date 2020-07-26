if [ ! -d "/flag/hostname" ] 
then
  mkdir -p /flag/hostname
  apt update && apt install -y jq
  VMNAME=$(onegate vm show --json | jq -r '.VM | .NAME' | sed -r 's/[_]+/-/g' | sed -r 's/[()]+//g')
  echo $VMNAME > /etc/hostname
  echo "127.0.0.1 $VMNAME" >> /etc/hosts
  reboot
fi

if [ ! -d "/flag/kubernetes_worker" ] 
then
  mkdir -p /flag/kubernetes_worker
  sudo apt-get update && sudo apt-get install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
  deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl docker.io
  sudo apt-mark hold kubelet kubeadm kubectl docker.io
  systemctl enable docker

  ID=$(onegate service show --json | jq -r ".SERVICE | .roles[0] | .nodes[0] | .deploy_id")
  CMD=$(onegate vm show $ID --json | jq -r ".VM | .USER_TEMPLATE | .CMD")

  echo $CMD > tmp.sh
  bash tmp.sh
fi