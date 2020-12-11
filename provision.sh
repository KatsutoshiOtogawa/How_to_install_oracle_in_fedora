dnf -y update

dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libcap1-1.10-7.el7.x86_64.rpm
dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
dnf -y install libnsl

# pre install packages.these packages are required expcept for oraclelinux.
curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm -L https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
dnf -y install oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
rm oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

# silent install oracle database.
mkdir /xe_logs 
ORACLE_PASSWORD=dicxwjelsicC3lDnrx3
curl -o oracle-database-xe-18c-1.0-1.x86_64.rpm -L https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm
echo finish downloading oracle database!
echo installing oracle database...
dnf -y install oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
rm oracle-database-xe-18c-1.0-1.x86_64.rpm

sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
(echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

# root user.
echo '# set oracle environment variable'  >> ~/.bash_profile
echo 'export ORACLE_SID=XE'  >> ~/.bash_profile
echo 'export ORAENV_ASK=NO'  >> ~/.bash_profile
echo 'export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE' >> ~/.bash_profile
echo 'export ORACLE_BASE=/opt/oracle' >> ~/.bash_profile
echo export PATH=\$PATH:\$ORACLE_HOME/bin >> ~/.bash_profile
echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> ~/.bash_profile
echo '' >> ~/.bash_profile

# oracle OS user.
su - oracle -c 'echo "# set oracle environment variable"  >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_SID=XE >> ~/.bash_profile'
su - oracle -c 'echo export ORAENV_ASK=NO >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_BASE=/opt/oracle  >> ~/.bash_profile'
su - oracle -c 'echo export PATH=\$PATH:\$ORACLE_HOME/bin >> ~/.bash_profile'
su - oracle -c "echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> ~/.bash_profile"
su - oracle -c 'echo "" >> ~/.bash_profile'


# change oracle databse mode to archive log mode.
su - oracle << END
echo "shutdown immediate" | sqlplus / as sysdba
echo "startup mount" | sqlplus / as sysdba
echo "ALTER DATABASE ARCHIVELOG;" | sqlplus / as sysdba
echo "ALTER DATABASE OPEN;" | sqlplus / as sysdba
END

# erase fragtation funciton. this function you use vagrant package.
cat << END >> ~/.bash_profile
# eraze fragtation.
function defrag () {
    dd if=/dev/zero of=/EMPTY bs=1M; rm -f /EMPTY
}
END