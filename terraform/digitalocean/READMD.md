# install fedora-oracle to digital ocean droplets

## terraform

## doctl
doctl is digital ocean 
```shell
brew install doctl

# set digital ocean access token.
doctl auth init
```

how to use
```shell
# show your projects list in digital ocean
doctl projects list

# create new project 
doctl projects create 

# show droplet image list
doctl compute image --public

# show avairable droplet hardware architecture
doctl compute

# show region list
doctl compute region list

# shoe project list

# show exists your ssh-key in digital-ocean
doctl compute ssh-key list

# shoe digital ocean existing your droplet.
doctl compute droplet list

# connect
doctl compute ssh *droplet_name* --ssh-key-path *~/.ssh/your_private_key*
```