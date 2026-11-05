insert into
    mqtt.users (username, password_hash, salt, is_superuser)
select
    'ct-pulse',
    encode(digest (v.password || v.salt, 'sha256'), 'hex'),
    v.salt,
    false
from
    (
        select
            'Ctgs2026'::text as password,
            encode(gen_random_bytes (16), 'hex') as salt
    ) v;

