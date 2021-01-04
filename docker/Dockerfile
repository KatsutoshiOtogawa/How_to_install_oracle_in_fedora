# LICENSE UPL 1.0
#
# Copyright (c) 2018, 2020 Oracle and/or its affiliates.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 18c Express Edition
# 
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# None
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run: 
#      $ docker build .
#
#
# Pull base image
# ---------------

FROM fedora:34

RUN dnf -y update

ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE \
    ORACLE_SID=XE \
    ORACLE_DOCKER_INSTALL=true \
    ORACLE_PASSWORD=password

# compat-libcap1,compat-libstdc++-33 required oracle database.
# these library needs fedora only.rhel,oracle linux are alredy installed.
RUN dnf -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libcap1-1.10-7.el7.x86_64.rpm \
                   http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm \
                   libnsl chkconfig

# pre install packages.these packages are required expcept for oraclelinux.
RUN dnf -y install https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

# downloading huge file.
RUN curl -o oracle-database-xe-18c-1.0-1.x86_64.rpm -L https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm

# install oracle datbaase.
RUN dnf -y install oracle-database-xe-18c-1.0-1.x86_64.rpm && \
    rm oracle-database-xe-18c-1.0-1.x86_64.rpm

ENV RUN_FILE="runOracle.sh" \
    PWD_FILE="setPassword.sh" \
    CONF_FILE="oracle-xe-18c.conf" \
    CHECK_SPACE_FILE="checkSpace.sh" \
    CHECK_DB_FILE="checkDBStatus.sh" 

COPY $CHECK_SPACE_FILE $RUN_FILE $PWD_FILE $CHECK_DB_FILE $CONF_FIL $ORACLE_BASE/

RUN chmod ug+x $ORACLE_BASE/*.sh

RUN mkdir -p $ORACLE_BASE/scripts/setup && \
    mkdir $ORACLE_BASE/scripts/startup && \
    ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
    mkdir -p $ORACLE_BASE/oradata /home/oracle && \
    chown -R oracle:oinstall $ORACLE_BASE /home/oracle && \
    mv $ORACLE_BASE/$CONF_FILE /etc/sysconfig/ && \
    ln -s $ORACLE_BASE/$PWD_FILE / && \
    cd $HOME

RUN dnf clean all

HEALTHCHECK --interval=1m --start-period=5m \
   CMD "$ORACLE_BASE/$CHECK_DB_FILE" >/dev/null || exit 1

CMD exec $ORACLE_BASE/$RUN_FILE
# set listener
# RUN sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf

# RUN (echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1


# CMD exec $ORACLE_BASE/$RUN_FILE