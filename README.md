# Opennuebula_Scripts
Automated scripts to deploy service on Opennebula ubuntu instance.


To use this, write a start script like this.
```
if [ ! -d "/flag" ]
then
  mkdir /flag
  cd /flag
  wget https://raw.githubusercontent.com/LEE-WAN/Opennuebula_Scripts/master/jupyter.sh
  bash jupyter.sh
fi
```
