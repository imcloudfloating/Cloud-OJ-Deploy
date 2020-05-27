# Linux Deploy Script
if [ "$1" == "-deploy" ]; then
    echo "Deploying Cloud-OJ..."
    # 拉取镜像
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/register-center:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/file-server:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/monitor-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/api-gateway:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/manager-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/judge-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/cloud-oj-web:latest
    # 部署
    docker stack deploy -c docker-stack.yml cloud_oj --with-registry-auth
elif [ "$1" == "-stop" ]; then
    echo "Stopping Cloud-OJ..."
    docker stack rm cloud_oj
elif [ "$1" == "-ps" ]; then
    docker stack ps cloud_oj --format "table {{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"
elif [ "$1" == "-clean" ]; then
    docker rmi $(docker images -q -f dangling=true)
else
    echo "arg:"
    echo "  -deploy    deploy services."
    echo "  -ps        show containers."
    echo "  -stop      stop and remove containers."
    echo "  -clean     delete dangling images."
fi