FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential gosu default-libmysqlclient-dev default-mysql-client pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY gregor_project/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt

COPY . /app

RUN useradd --create-home --shell /bin/bash appuser \
    && chmod +x /app/gregor_project/setup_script.py /app/gregor_project/gregor_project/entrypoint.sh \
    && chown -R appuser:appuser /app

EXPOSE 8000

ENTRYPOINT ["/app/gregor_project/gregor_project/entrypoint.sh"]
CMD ["/app/gregor_project/setup_script.py"]
