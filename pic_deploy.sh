#!/bin/sh


    DOCKER_DIR=/root/picuang
    mkdir -p $DOCKER_DIR
    cd $DOCKER_DIR

    #如果存在旧的blog文档，则删除
    if [ -d "picuang" ];
    then
        echo "rm dir picuang"
        rm -rf picuang
        sleep 10
        echo "rm over"
    else
        echo "dir picuang not exit"
    fi

    #从远程仓库clone到服务器
    git clone https://github.com/XXMLP/picuang.git

    echo "git clone over"
    #打包
    cd $DOCKER_DIR/picuang
    mvn package

    sleep 10
    echo "package over"

    cd $DOCKER_DIR
    #删除原有的文件
    rm -f Dockerfile
    rm -f picuang-0.0.1-SNAPSHOT.war

    mv $DOCKER_DIR/picuang/target/picuang-0.0.1-SNAPSHOT.jar .
    mv $DOCKER_DIR/picuang/Dockerfile .

    #删除旧的镜像和容器
    docker stop picuang
    docker rm picuang
    docker rmi picuang:1.0
    sleep 10
    #打包成镜像
    #说明:
    #  blog   代表要打包成的镜像名称。按照自己实际情况写。
    #  :1.0   代表版本号，可以不写则默认为latest
    #  .    代表为当前目录。这就是为什么一直在步骤一文件夹中进行操作,并且Dockerfile在此文件夹中的原因。
    #
    #若之前Dockerfile不在步骤一的文件夹中 则需要指定到对应的地址
    docker build -t picuang:1.0 .
    #启动容器，前提是已开放这个端口
    docker run --name picuang -d -p 8081:8081 picuang:1.0
    #单元测试，动态代码覆盖率的获取
    #mvn clean verify -f pom_cc.xml
    #jar -xvf blog-0.0.1-SNAPSHOT.jar
    #java -javaagent:jacocoagent.jar=includes=*,output=tcpserver,port=2015,address=localhost -jar blog-0.0.1-SNAPSHOT.jar
    #mvn clean verify -f pom_onthefly.xml