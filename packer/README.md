# how to create vagrant box
```
packer build --only=virtualbox-iso fedora.json

vagrant box add localhost/fedora33-oracle-xe-18 fedora33-oracle-xe-18.box
```

# kickstart
ks.cfg is reference from /root/anaconda.cfg in [fedora-33-cloud-base](https://app.vagrantup.com/fedora/boxes/33-cloud-base).
# Reference

[Box cutter fedora](https://github.com/boxcutter/fedora)

[kickstart method](http://honana.com/system/kickstart)