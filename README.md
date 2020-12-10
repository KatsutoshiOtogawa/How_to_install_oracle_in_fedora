# How_to_install_oracle_in_fedora

```
# experiment in fedora-32,fedora-33.

# compat-libcap1,compat-libstdc++-33 required oracle database.
# these library needs fedora only.rhel,oracle linux are alredy installed.
dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libcap1-1.10-7.el7.x86_64.rpm
dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
dnf -y install libnsl

# pre install packages.these packages are required expcept for oraclelinux.
curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
dnf -y install oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

# silent install oracle database.
mkdir /xe_logs 
ORACLE_PASSWORD=yourpassword
curl -o oracle-database-xe-18c-1.0-1.x86_64.rpm https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm
dnf -y install oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
(echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1
```

```
# oracle database launch and, be available.

# these command is operationing in oracle user. oracle user belong to dbaoper.
echo "startup;" | sqlplus / as sysdba
launchctl start
```
