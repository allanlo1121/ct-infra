# 1. 创建持久化目录
mkdir -p data log

# 2. 设置目录所有权
sudo chown -R 1000:1000 data log

# 3. 设置目录权限
sudo chmod -R u+rwX,g+rwX,o-rwx data log

# 4. 启动 EMQX
docker compose up -d

Server:
db:5432

Database:
postgres

Username:
emqx_user

Password:
CHANGE_ME_STRONG_PASSWORD

SELECT
password_hash,
salt
FROM eqp.mqtt_user
WHERE username = ${username}
LIMIT 1

SELECT permission, action, topic
FROM eqp.mqtt_acl
WHERE username = ${username}
