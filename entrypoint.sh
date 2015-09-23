set -e

if [[ -z "$(which openssl)" ]]; then
  echo 'openssl not found in path, cannot continue.' >&2
  exit 1
fi

if [[ -z "$VIRTUAL_HOST" ]]; then
  sed -ri \
    's/^\s*ServerName\s+\{\{\s*server_name\s*\}\}\s*$//g' \
    /etc/apache2/apache2.conf
else
  if [[ -z "$(egrep '^[a-zA-Z\.]{3,}$' <<<"$VIRTUAL_HOST")" ]]; then
    echo 'Invalid hostname "'"$VIRTUAL_HOST"'", cannot continue.' >&2
    exit 1
  fi
  sed -ri \
    's/^(\s*ServerName\s+)\{\{\s*server_name\s*\}\}\s*$/\1'"$VIRTUAL_HOST"'/g' \
    /etc/apache2/apache2.conf
fi

if [[ -z "$ADMIN_USER" || -z "$ADMIN_PASSWORD" ]]; then
  ADMIN_USER=nagiosadmin
  ADMIN_PASSWORD=nagios
fi

_hash=$(echo -n "$ADMIN_PASSWORD" | openssl sha1 -binary | base64)
echo "$ADMIN_USER:{SHA}$_hash" > /etc/nagios3/htpasswd.users

. /etc/apache2/envvars
/usr/sbin/apache2 -D 'FOREGROUND' -f 'apache2.conf'

set +e
