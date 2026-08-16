目录

```bash
/opt
└── ct-infra
    ├── supabase/
    │   ├── config.toml
    │   ├── migrations/
    │   └── seed.sql
    │
    ├── docker/
    │   └── compose.yml
    │
    ├── apps/
    │   ├── web/          # Next.js
    │   └── realtime/     # MQTT处理服务
    │
    ├── services/
    │   └── mosquitto/
    │
    ├── scripts/
    │
    └── .env
```


```bash
sudo mkdir -p /opt/ct-infra
sudo chown -R $USER:$USER /opt/ct-infra
cd /opt/ct-infra
supabase start
```