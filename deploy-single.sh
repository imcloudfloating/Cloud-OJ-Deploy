# Linux Single-Node Deploy
# 拉取镜像
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/register-center
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/file-server
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/monitor-service
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/api-gateway
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/manager-service
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/judge-service
docker pull registry.cn-hangzhou.aliyuncs.com/cloudli/cloud-oj-web
# 部署
docker-compose up -d