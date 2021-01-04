# docker

```shell
# build
docker build -t localhost/fedora33-oracle-xe-18:1.0 .

# save image
docker save localhost/fedora33-oracle-xe-18 -o fedora33-oracle-xe-18.tar
```

# reference
[Oracle Docker image 18.4.0](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/18.4.0)

copy file checkDBStatus.sh checkSpace.sh oracle-xe-18c.conf runOracle.sh setPassword.sh from [Oracle Docker image 18.4.0](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance/dockerfiles/18.4.0)
