# Linux Deploy Script
if [ "$1" == "--deploy" ]; then
    echo "Deploying on Docker Swarm..."
    # 在Swarm模式下部署
    docker stack deploy -c docker-stack.yml cloud_oj --with-registry-auth
elif [ "$1" == "--deploy-single" ]; then
    # 单节点部署
    echo "deploying by docker-compose..."
    docker-compose up -d
elif [ "$1" == "--stop" ]; then
    echo "stopping cloud_oj..."
    docker stack rm cloud_oj
elif [ "$1" == "--stop-single" ]; then
    echo "stopping..."
    docker-compose down
elif [ "$1" == "--ps" ]; then
    docker stack ps cloud_oj --format "table {{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"
elif [ "$1" == "--update-images" ]; then
    # 拉取最新镜像
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/register-center:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/file-server:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/monitor-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/api-gateway:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/manager-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/judge-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/cloud-oj-web:latest
else
    echo "arg:"
    echo "      --deploy            deploy on Docker Swarm."
    echo "      --deploy-single     deploy on single node."
    echo "      --update-images     update images to latest."
    echo "      --ps                list services on Docker Swarm."
    echo "      --stop              stop and remove containers."
    echo "      --stop-single       stop the services deployed by docker-compose."
fi