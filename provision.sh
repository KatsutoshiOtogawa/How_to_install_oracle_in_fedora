dnf -y update

# for download sample shcmea.
dnf -y install git

# install firewalld. firewalld is rhel,centos default dynamic firewall.
dnf -y install firewalld

# enabla firewalld.
systemctl enable firewalld
systemctl start firewalld

# port forwarding oracle port 1521.
firewall-cmd --add-port=1521/tcp --zone=public --permanent

# reload firewall settings.
firewall-cmd --reload

# compat-libcap1,compat-libstdc++-33 required oracle database.
# these library needs fedora only.rhel,oracle linux are alredy installed.
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

source ~/.bash_profile

# add setting connecting to XEPDB1 pragabble dababase.
cat << END >> $ORACLE_HOME/network/admin/tnsnames.ora

XEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XEPDB1)
    )
  )

END

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

cat << END >> ~/.bash_profile
# create sample from github
# reference from [Oraclesite: Database Sample Schemas](https://docs.oracle.com/en/database/oracle/oracle-database/18/comsc/lot.html)
# you want to know this script detail, go to https://github.com/oracle/db-sample-schemas.git
function enable_sampleschema () {
    # sample respository is huge. get recent coomit only.
    git clone --depth 1 https://github.com/oracle/db-sample-schemas.git -b v19.2 \$HOME/db-sample-schemas
    local backdir=\$(pwd)
    cd \$HOME/db-sample-schemas
    # get release source
    git checkout 5d236bf4178322716963f173f4b8f6a0c987a0dd
    perl -p -i.bak -e 's#__SUB__CWD__#'\$(pwd)'#g' *.sql */*.sql */*.dat
    # add exit for exiting sqlplus.
    echo '' >> mksample.sql
    echo 'exit' >> mksample.sql
    mkdir \$HOME/dbsamples
    sqlplus system/\${ORACLE_PASSWORD}@XEPDB1 @mksample \$ORACLE_PASSWORD \$ORACLE_PASSWORD hrpw oepw pmpw ixpw shpw bipw users temp \$HOME/dbsamples/dbsamples.log XEPDB1

    # install OC schema
    cd customer_orders
    echo '' >> co_main.sql
    echo 'exit' >> co_main.sql
    sqlplus system/\${ORACLE_PASSWORD}@XEPDB1 @co_main copw XEPDB1 users temp

    cd $backdir >> /dev/null
    rm -rf \$HOME/db-sample-schemas

}

function disable_sampleschema () {
    # sample respository is huge. get recent coomit only.
    git clone --depth 1 https://github.com/oracle/db-sample-schemas.git -b v19.2 \$HOME/db-sample-schemas
    local backdir=\$(pwd)
    cd \$HOME/db-sample-schemas
    # get release source
    git checkout 5d236bf4178322716963f173f4b8f6a0c987a0dd
    perl -p -i.bak -e 's#__SUB__CWD__#'\$(pwd)'#g' *.sql */*.sql */*.dat
    # add exit for exiting sqlplus.
    echo '' >> drop_sch.sql
    echo 'exit' >> drop_sch.sql
    sed -i "s/^DEFINE pwd_system/DEFINE pwd_system = \\'\$ORACLE_PASSWORD\\'/" drop_sch.sql
    sed -i "s|^DEFINE spl_file|DEFINE spl_file = \\'\$HOME/dbsamples/drop_sch.log\\'|" drop_sch.sql
    sed -i "s/^DEFINE connect_string/DEFINE connect_string = 'XEPDB1'/" drop_sch.sql
    
    sqlplus system/\${ORACLE_PASSWORD}@XEPDB1 @drop_sch
    cd customer_orders
    # add exit for exiting sqlplus.
    echo '' >> co_drop_user.sql
    echo 'exit' >> co_drop_user.sql
    sqlplus system/\${ORACLE_PASSWORD}@XEPDB1 @co_drop_user 

    cd $backdir >> /dev/null
    rm -rf \$HOME/db-sample-schemas

}

END

# Erase fragtation funciton. This function is useful when you create vagrant package.
cat << END >> ~/.bash_profile
# eraze fragtation.
function defrag () {
    dd if=/dev/zero of=/EMPTY bs=1M; rm -f /EMPTY
}
END

reboot
