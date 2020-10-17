# Cloud OJ Deploy Script

Cloud OJ 部署脚本（仅支持 Docker）
项目源码：[Cloud-OJ](https://github.com/imcloudfloating/Cloud-OJ)

## 目录结构

```bash
│  cloud-oj.cmd         # Windows 部署脚本，一般用不上
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

> 如果你非常熟悉 Docker、Docker Swarm，可以忽略部署脚本。

## 部署指南

此部署脚本基于 Docker、Docker Swarm 部署，请先安装并配置好 Docker。

设置环境变量：

- 编排文件中的连接池和线程池根据 CPU 核心数配置。

### 1. 单机部署

单机部署使用的编排文件是 `docker-compose.yml`，内容可根据需求修改。

部署：

```bash
./cloud-oj.sh --deploy-single
```

```bash
./cloud-oj.cmd --deploy-single
```

### 2. 集群模式

搭建 Docker Swarm 集群，集群模式需要使用 NFS 存储测试数据，搭建 NFS 并修改 `docker-stack.yml` 中的以下部分：

```yaml
volumes:
  oj_file:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.1.6,rw"      # NFS IP 地址
      device: ":/oj_file"           # 挂载目录
```

#### NFS 权限问题

挂载的 NFS 目录可能无法写入文件，必须设置容器的 `uid` 与宿主机一致：

```yaml
file_server:
  image: ...
  user: "1000"   # 指定 uid
```

- 对于 Docker on Linux，如果你使用 root 用户运行的 Docker，也许可以不用设置 `uid`，如果不是，请先使用 `id <用户名>` 命令查看 `uid`，然后将 `docker-stack.yml` 中的 `user` 部分替换；
- 对于 Docker Desktop for Windows，直接将 `user` 设为 `1000` 即可。

#### 设置服务的节点

对于 MySQL 和 RabbitMQ，务必指定节点（ `node.hostname` 或者 `node.role`）以避免重新部署时节点发生改变出现数据消失的现象，默认设置为在管理节点部署。

```yaml
deploy:
  placement:
    constraints:
      - node.role == worker   # 指定部署节点
```

> 也可以使用 `node.hostname` 或者 `node.labels.role` 来更精确指定，可用 `docker node ls` 查看 Swarm 节点。具体可参考 [Docker 官方文档](https://docs.docker.com/compose/compose-file/#placement)。

部署：

```bash
./cloud-oj.cmd --deploy
```

```bash
./cloud-oj.sh --deploy
```

- 使用 `--stop` 参数可以停止并删除容器（不会删除数据卷）；
- 如果 NFS 服务器的 IP 变更，请删除 `oj_file` 卷后再重新部署；
- 由于 Docker Swarm 中使用 overlay 网络时容器存在多网卡，编排文件中已经将子网设置为 `10.16.0.0/16`，请勿更改。

> 系统初始管理员用户名和密码均为 `root`。

### 配置 HTTPS

> 提示：如果不需要使用 HTTPS，请忽略这部分。

#### 单机部署的配置方法

修改 `web` 部分，将含有 SSL 证书和 Key 的目录挂载到容器的 `/ssl` 目录下

```yaml
web:
  ...
  ports: 
    - "80:80"
    - "443:443"
  volumes:
    - "宿主机SSL证书目录:/ssl"
  environment:
    API_HOST: "gateway"
    ENABLE_HTTPS: "true"
    EXTERNAL_URL: "Domain or IP"    # 用于 http 自动转 https，填写 IP 或域名
    SSL_CERT: "example.pem"         # SSL 证书文件名，pem 或 crt 文件
    SSL_KEY: "example.key"          # SSL Key 文件名
```

> `EXTERNAL_URL` 若不设置，那么必须手动加上 `https://` 才能打开网站。

#### 集群部署的配置方法

如果使用 Docker Swarm 部署，SSL 证书需要使用 `configs`。修改 `docker-stack.yml` 文件，添加 SSL 证书的 `configs`：

```yaml
configs:
  ssl_cert:
    file: .pem/.crt 文件的路径
  ssl_key:
    file: .key 文件的路径
```

修改 `web` 部分，增加 `configs`，其它部分与单机部署相同：

```yaml
web:
  ...
  configs:
    - source: ssl_cert
      target: /ssl/example.pem
    - source: ssl_key
      target: /ssl/example.key
  environment:
    ...
    SSL_CERT: "example.pem"
    SSL_KEY: "example.key"
```

> 提示：如果你使用的是 Docker Desktop for Windows，那么配置 HTTPS 后可能会出现 403 的情况。

## 环境变量

| Environment Name    | 说明
| ------------------- | -------------------------------
| EUREKA_SERVER       | 注册中心，填写注册中心的服务名
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
| oj_file   | 存放测试数据、图片等文件（集群部署时需要挂载 NFS）
| target    | 临时存放代码和编译产生的可执行文件
