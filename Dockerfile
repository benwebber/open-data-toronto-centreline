FROM python:3.13-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:0.7.17 /uv /uvx /bin/
ADD . /app
WORKDIR /app
RUN uv venv /opt/venv
RUN uv pip install --requirements requirements.txt --system
CMD ["datasette", "serve", "--metadata", "metadata.yaml", "--host", "0.0.0.0", "--port", "8000", "centreline.db"]
