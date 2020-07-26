if [ ! -d "/flag/hostname" ] 
then
  mkdir -p /flag/hostname
  apt update && apt install -y jq
  VMNAME=$(onegate vm show --json | jq -r '.VM | .NAME')
  echo $VMNAME > /etc/hostname
  echo "127.0.0.1 $VMNAME" >> /etc/hosts
fi
if [ ! -d "/flag/jupyter" ] 
then
  mkdir -p /flag/jupyter
  cd /flag/jupyter
  mkdir -p /root/workspace
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
  bash ./miniconda.sh -b -p /root/miniconda
  rm ./miniconda.sh
  /root/miniconda/bin/conda install -y -c anaconda jupyter
  /root/miniconda/bin/jupyter notebook --generate-config

  echo "export PATH=$PATH:/root/miniconda/bin" >> /root/.bashrc
  
  echo "$(cat <<-EOF
c.NotebookApp.port = 10000
c.NotebookApp.allow_remote_access = True
c.NotebookApp.allow_root = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.notebook_dir = '/root/workspace'
c.NotebookApp.password = ''
c.NotebookApp.token = ''
EOF
)" >> /root/.jupyter/jupyter_notebook_config.py

  echo "$(cat <<-EOF
  [Unit]
  Description=Jupyter Notebook

  [Service]
  Type=simple
  PIDFile=/run/jupyter.pid
  ExecStart=/root/miniconda/bin/jupyter notebook
  WorkingDirectory=/root/workspace
  Restart=always
  RestartSec=10
  #KillMode=mixed

  [Install]
  WantedBy=multi-user.target
EOF
)" > /etc/systemd/system/jupyter.service
  systemctl enable jupyter.service
  reboot
fi