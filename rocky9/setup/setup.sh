## Apply updates
echo '-- Applying package updates ...'
sudo dnf update -y -q &>/dev/null

## Install core packages
echo '-- Installing additional packages ...'
sudo dnf install -y -q ca-certificates dnf-plugins-core &>/dev/null
sudo dnf install -y -q perl python3 &>/dev/null

## Adding additional repositories
echo '-- Adding repositories ...'
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo &>/dev/null
sudo rpm --import https://repo.saltproject.io/salt/py3/redhat/9/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub &>/dev/null
curl -fsSL https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo &>/dev/null

## Cleanup yum
echo '-- Clearing yum cache ...'
sudo dnf clean all &>/dev/null

## Configure SSH server
echo '-- Configuring SSH server daemon ...'
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

## Configure cloud-init
# echo '-- Configuring cloud-init ...'
# sudo cat << CLOUDCFG > /etc/cloud/cloud.cfg.d/99-vmware-guest-customization.cfg
# disable_vmware_customization: false
# datasource:
#   VMware:
#     vmware_cust_file_max_wait: 20
# CLOUDCFG

## Final cleanup actions
echo '-- Executing final cleanup tasks ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
fi
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -f /etc/machine-id
# sudo cloud-init clean --logs --seed
sudo rm -f /etc/ssh/ssh_host_*
if [ -f /var/log/audit/audit.log ]; then
    sudo cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    sudo cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    sudo cat /dev/null > /var/log/lastlog
fi
echo '-- Configuration complete'