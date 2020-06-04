#! /usr/bin/env bash
#
# waits for admin password
until [[ -f /nexus-data/admin.password ]] || [[ -f /nexus-data/admin-password-changed ]]; do
    sleep 5
done

# used to return NOT_DEFINED
test -f /nexus-data/admin.password && cat /nexus-data/admin.password || echo 'ADMIN_PASSWORD_ALREADY_CHANGED'
