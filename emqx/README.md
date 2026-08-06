mkdir -p data log

sudo chown -R 1000:1000 data log
sudo chmod -R 777 data log

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
