# Cloud OJ Docker Deploy

这是一个微服务架构的 OJ，基于 [Spring Cloud](https://spring.io/projects/spring-cloud/)，使用 Docker 部署。
本系统参考了 [HUSTOJ](https://github.com/zhblue/hustoj)，功能上目前比较简陋。

![Commit Code](https://note-and-blog.oss-cn-beijing.aliyuncs.com/cloud_oj/commit_code.png)

支持的语言：

- C/C++
- Java
- Python
- C#
- Bash Shell

## 环境变量

名称                | 说明
--------------------|----------------------------------------------------
EUREKA_SERVER       | 注册中心，填写注册中心的服务名
GATEWAY_HOST        | 网关的 IP，填写网关所在的宿主机的 IP（不能写 localhost）
MYSQL_URL           | 数据库的 URL
MYSQL_USER          | 连接数据库的用户（默认值为 root）
MYSQL_ROOT_PASSWORD | MySQL root 用户的密码
MYSQL_PASSWORD      | 数据库的密码（默认值为 cloud） 
DB_POOL_SIZE        | 数据库连接池大小
RABBIT_URL          | RabbitMQ 的 IP
RABBIT_PORT         | RabbitMQ 的 端口（默认值为 5672）
RABBIT_USER         | RabbitMQ 的用户名
RABBIT_PASSWD       | RabbitMQ 的密码
CORE_POOL_SIZE      | 线程池基本大小
MAX_POOL_SIZE       | 线程池最大值
QUEUE_CAPACITY      | 线程池队列大小

- 以上环境变量，无特殊需要只用将 `GATEWAY_HOST` 填写为本机 IP 即可
- 单机部署时使用 `docker-compose.yml`，集群部署使用 `docker-stack.yml`
- 连接池和线程池根据 CPU 核心数来配置

## 卷

> 见 `docker-compose.yml` or `docker-stack.yml` 文件中的 `volumes`部分。

volume      | 说明
------------|----------------------------------
mysql       | MySQL 数据目录
rabbit      | RabbitMQ 数据目录
test_data   | 存放测试数据（集群部署时请使用NFS）
target      | 临时存放代码和编译产生的可执行文件

## 部署与运行

请先安装并配置 Docker，集群部署需要配置 Docker Swarm。

### 单机模式

以下脚本会自动拉取镜像并部署：

```shell
deploy-single.cmd
```

```shell
deploy-single.sh
```

### 集群模式

Docker 开启 Swarm 模式，使用 `cloud-oj.sh` 或 `cloud-oj.cmd` 脚本部署。

集群模式使用 NFS 存储测试数据，搭建 NFS 并修改 `docker-stack.yml` 中的以下部分即可：

```yaml
volumes:
  test_data:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.1.6,rw"          # NFS IP 地址
      device: ":/oj-file/test_data"     # NFS 目录
```

> 对于 MySQL 和 RabbitMQ，务必指定节点（ `node.hostname` ）以避免重新部署时节点改变出现数据消失的现象，可以使用 `docker node ls` 查看。

```shell
cloud-oj.cmd -deploy
```

```shell
cloud-oj.sh -deploy
```

> - 使用 `-stop` 参数可以停止并删除容器（不会删除数据卷）。
> - 如果 NFS 服务器的 IP 变更，请删除 test_data 卷后再重新部署。

### Web 页面

- 监控中心：`http://YOUR_IP_ADDRESS:5000`
- 注册中心：`http://YOUR_IP_ADDRESS:8761`
- OJ 主页：`http://YOUR_IP_ADDRESS/oj/`

### 说明

- `GATEWAY_HOST` 设置为部署机器的 IP，不可使用 `localhost` 或 `127.0.0.1`;
- 在部署机器上访问网页时，要使用本机 IP，不可使用 `localhost` 或 `127.0.0.1`，会出现跨域问题.
