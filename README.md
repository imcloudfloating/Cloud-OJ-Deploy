# Cloud OJ Deploy Script

Cloud OJ 自动部署脚本，项目源码：[Cloud-OJ](https://github.com/imcloudfloating/Cloud-OJ)。

![Index Page](index-page.png)

## 支持的语言

- C
- C++ 14
- Java 1.8
- Python 3.5
- Bash Shell
- C#

## 目录结构

```bash
│  .gitignore
│  cloud-oj.cmd         # Windows 部署脚本
│  cloud-oj.sh          # Linux 部署脚本
│  docker-compose.yml   # 单机部署的编排文件
│  docker-stack.yml     # 集群部署的编排文件
│  LICENSE
│  README.md
│
└─mysql
    ├─config
    │      my.cnf       # MySQL 配置文件
    │
    └─sql
           init_cloud_oj.sql   # 数据库初始化脚本
```

## 部署指南

此部署脚本基于 Docker、Docker Swarm 部署，请先安装并配置好 Docker。

设置环境变量：

1. 将编排文件中的 `GATEWAY_HOST` 填写为服务器的 IP 或域名（需要加协议前缀 `http`）；
2. 编排文件中的连接池和线程池根据 CPU 核心数配置。

> 如果你非常熟悉 Docker、Docker Swarm，可以忽略部署脚本.

> 假如 sh 脚本报错，请将换行符改为 `LF`。

### 单机部署

单机部署使用的编排文件是 `docker-compose.yml`，部署命令：

```bash
./cloud-oj.sh --deploy-single
```

```bash
./cloud-oj.cmd --deploy-single
```

### 集群模式

搭建 Docker Swarm 集群，集群模式需要使用 NFS 存储测试数据，
自行搭建 NFS 并修改 `docker-stack.yml` 中的以下部分即可：

```yaml
volumes:
  test_data:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.1.6,rw"          # NFS IP 地址
      device: ":/oj-file/test_data"     # 挂载目录
```

#### NFS 权限问题

挂载的 NFS 目录可能无法写入文件，必须设置容器的 `uid` 与宿主机一致：

```yaml
file_server:
  image: ...
  user: "1000"   # 指定 uid
```

- 对于 Docker on Linux，如果你使用 root 用户运行的 Docker，也许可以不用设置 `uid`，如果不是，
请先使用 `id <用户名>` 命令查看 `uid`，然后将 `docker-stack.yml` 中的 `user` 部分替换；
- 对于 Docker Desktop for Windows，直接将 `user` 设为 `1000` 即可。

#### 设置服务的节点

对于 MySQL 和 RabbitMQ，务必指定节点（ `node.hostname` 或者 `node.role`）以避免重新部署时节点发生改变出现数据消失的现象，默认设置为在管理节点部署。



```yaml
deploy:
  placement:
    constraints:
      - node.role == worker   # 指定部署节点
```

> 也可以使用 `node.hostname` 或者 `node.labels.role` 来更精确指定，
> 可用 `docker node ls` 查看 Swarm 节点。
> 具体可参考 [Docker 官方文档](https://docs.docker.com/compose/compose-file/#placement)。

部署命令：

```bash
./cloud-oj.cmd --deploy
```

```bash
./cloud-oj.sh --deploy
```

- 使用 `--stop` 参数可以停止并删除容器（不会删除数据卷）；
- 如果 NFS 服务器的 IP 变更，请删除 test_data 卷后再重新部署；
- 由于 Docker Swarm 中使用 overlay 网络时容器存在多网卡，编排文件中已经将子网设置为 `10.16.0.0/16`，请勿更改。

### Web 页面

- OJ 主页：`http://HOST_NAME`
- 监控中心：`http://HOST_NAME:5000`
- 注册中心：`http://HOST_NAME:8761`

> 系统初始管理员用户名和密码均为 `root`。

## 环境变量

| Environment Name    | 说明
| ------------------- | --------------------------------
| EUREKA_SERVER       | 注册中心，填写注册中心的服务名
| GATEWAY_HOST        | 路由网关的主机名，该值给前端使用
| MYSQL_URL           | 数据库的 URL
| MYSQL_USER          | 用于连接数据库的用户
| MYSQL_ROOT_PASSWORD | MySQL root 用户的密码
| MYSQL_PASSWORD      | 数据库的密码
| DB_POOL_SIZE        | 数据库连接池大小
| RABBIT_URL          | RabbitMQ 的 IP
| RABBIT_PORT         | RabbitMQ 的 端口
| RABBIT_USER         | RabbitMQ 的用户名
| RABBIT_PASSWORD     | RabbitMQ 的密码
| CORE_POOL_SIZE      | 判题线程池基本大小
| MAX_POOL_SIZE       | 判题线程池最大值
| QUEUE_CAPACITY      | 判题线程池队列大小

## 数据卷

| Volume    | 说明
| --------- | ----------------------------------
| mysql     | MySQL 数据
| rabbit    | RabbitMQ 数据
| log       | 存放服务的日志文件
| test_data | 存放测试数据（集群部署时挂载 NFS）
| target    | 临时存放代码和编译产生的可执行文件
