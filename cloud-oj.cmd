:: Windows Deploy Script
@if "%1" == "-deploy" (
    @echo Deploying Cloud-OJ...
    :: 拉取镜像
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/register-center:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/file-server:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/monitor-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/api-gateway:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/manager-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/judge-service:latest
    docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/cloud-oj-web:latest
    :: 部署
    docker stack deploy -c docker-stack.yml cloud_oj --with-registry-auth
) else if "%1" == "-stop" (
    @echo Stopping Cloud-OJ...
    docker stack rm cloud_oj
) else if "%1" == "-ps" (
    docker stack ps cloud_oj --format "table {{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"
) else (
    @echo arg:
    @echo   -deploy     deploy services.
    @echo   -ps         show containers.
    @echo   -stop       stop and remove containers.
    @pause
)