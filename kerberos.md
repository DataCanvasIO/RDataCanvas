1. add environment param:
    ```shell
    isValidate = true
    kerberosConfig = {"kdcLocation":"124.42.117.60","kServer":"124.42.117.60","kUserName":"wuhaifeng@TEST.COM","keyTabServer":"124.42.117.75","keyTabPort":"18185"}
    ```
2. command
    ```shell
    kinit -kt hdfs.keytab hdfs/cdh1.test.com@TEST.COM
    ```