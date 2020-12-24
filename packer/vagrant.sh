#!/bin/bash -eux

echo "==> Configuring settings for vagrant"

# Add vagrant user (if it doesn't already exist)
if ! id -u vagrant >/dev/null 2>&1; then
  echo '==> Creating vagrant'
  /usr/sbin/groupadd vagrant
  /usr/sbin/useradd vagrant -g vagrant
  echo vagrant|passwd --stdin vagrant
fi

# Give Vagrant user permission to sudo
echo "Defaults:vagrant !requiretty" > /etc/sudoers.d/vagrant
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

echo '==> Installing Vagrant SSH key'
mkdir -pm 700 /home/vagrant/.ssh
# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# usermod -aG xrdp vagrant
# usermod -aG ssl-cert xrdp

systemctl enable xrdp

systemctl enable firewalld
systemctl start firewalld

# 3350
firewall-cmd --permanent --zone=public --add-port=3389/tcp
firewall-cmd --reload

chcon –type=bin_t /usr/sbin/xrdp
chcon –type=bin_t /usr/sbin/xrdp-sesman

# cleanup
echo "==> Clear out machine id"
rm -f /etc/machine-id
touch /etc/machine-id

echo "==> Cleaning up dnf cache of metadata and packages to save space"
dnf -y clean all

echo "==> Removing temporary files used to build box"
rm -rf /tmp/*

echo "==> Zeroing out empty area to save space in the final image"
# Zero out the free space to save space in the final image.  Contiguous
# zeroed space compresses down to nothing.
dd if=/dev/zero of=/EMPTY bs=1M || echo "dd exit code $? is suppressed"
rm -f /EMPTY

# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync

echo "==> Disk usage after cleanup"
df -h