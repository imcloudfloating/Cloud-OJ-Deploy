:: Windows Deploy Script
@if "%1" == "-deploy" (
    @echo deploying on Docker Swarm...
    docker stack deploy -c docker-stack.yml cloud_oj --with-registry-auth
) else if "%1" == "--deploy-single" (
    @echo deploying by docker-compose...
    docker-compose up -d
) else if "%1" == "--stop" (
    @echo stopping cloud_oj...
    docker stack rm cloud_oj
) else if "%1" == "--stop-single" (
    @echo stopping...
    docker-compose down
) else if "%1" == "--ps" (
    docker stack ps cloud_oj --format "table {{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"
) else if "%1" == "--update-images" (
    :: 拉取最新镜像
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/register-center:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/file-server:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/monitor-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/api-gateway:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/manager-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/judge-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/cloud-oj-web:latest
) else (
    @echo arg:
    @echo       --deploy            deploy on Docker Swarm.
    @echo       --deploy-single     deploy on single node.
    @echo       --update-images     update images to latest.
    @echo       --ps                list services on Docker Swarm.
    @echo       --stop              stop the services deployed on Docker Swarm.
    @echo       --stop-single       stop the services deployed by docker-compose.
)
@pause