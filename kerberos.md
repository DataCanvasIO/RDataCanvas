1. add environment param:
    ```shell
    export ZETRT=global.json
    export isValidate=true
    export kerberosConfig='{"kdcLocation":"124.42.117.60","kServer":"124.42.117.60","kUserName":"wuhaifeng@TEST.COM","keyTabServer":"124.42.117.75","keyTabPort":"18185"}'
    ```
2. command
    ```shell
    kinit -kt hdfs.keytab hdfs/cdh1.test.com@TEST.COM
    ```
    
## 安装R包
1. install R package
    ```shell
    sudo R CMD INSTALL RDataCanvas_0.1.1.tar.gz
    ```