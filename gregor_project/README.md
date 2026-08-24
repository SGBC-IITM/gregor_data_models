# GREGoR Django Admin

This local Django project provides an SQLite-backed admin workspace for exploring
the GREGoR data model and testing CRUD operations.

## Run locally

```bash
cd gregor_project
source .venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

Open <http://127.0.0.1:8000/admin/> and sign in with the superuser account.