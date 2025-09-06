#!/bin/sh
set -e

# fix CRLF if you edited this on Windows
# sed -i 's/\r$//' /entrypoint.sh 2>/dev/null || true

python manage.py migrate --noinput
python manage.py collectstatic --noinput

# create a superuser once if missing
python <<'PY'
import os
from django.contrib.auth import get_user_model
from django.core.management import BaseCommand
from django.db import IntegrityError

User = get_user_model()
username = os.environ.get("DJANGO_SUPERUSER_USERNAME", "admin")
email = os.environ.get("DJANGO_SUPERUSER_EMAIL", "admin@example.com")
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD", "admin123")

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print("Superuser created:", username)
else:
    print("Superuser exists, skipping:", username)
PY

exec "$@"
