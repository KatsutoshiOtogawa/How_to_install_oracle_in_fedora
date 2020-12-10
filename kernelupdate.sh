dnf update -y

# virtual box guest addition plugin is require kernel update.
# this operation is only need fedora.
dnf -y update kernel-core kernel-devel kernel-headers
