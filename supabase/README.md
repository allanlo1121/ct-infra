
docker ps -aq --filter "name=supabase" | % { docker rm -f $_ }

supabase start

supabase init

supabase db reset