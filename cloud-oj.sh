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
else
    echo "arg:"
    echo "      --deploy            deploy on Docker Swarm."
    echo "      --deploy-single     deploy on single node."
    echo "      --ps                list services on Docker Swarm."
    echo "      --stop              stop services deployed by docker swarm."
    echo "      --stop-single       stop services deployed by docker-compose."
fi