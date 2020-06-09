:: Windows Deploy Script
@if "%1" == "--deploy" (
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
) else (
    @echo arg:
    @echo       --deploy            deploy on Docker Swarm.
    @echo       --deploy-single     deploy on single node.
    @echo       --ps                list services on Docker Swarm.
    @echo       --stop              stop the services deployed on Docker Swarm.
    @echo       --stop-single       stop the services deployed by docker-compose.
)
@pause