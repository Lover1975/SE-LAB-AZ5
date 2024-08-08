# Dockerfile

FROM python:3.9

WORKDIR /app

RUN apt-get update && apt-get install -y netcat-openbsd

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

ENV DJANGO_SETTINGS_MODULE=notes.settings

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
