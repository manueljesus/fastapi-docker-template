# Base stage: Build and install dependencies
FROM python:3.12.5-slim-bookworm AS builder

# Set the environment mode to production by default
ARG BUILD_MODE=production
RUN echo "BUILD_MODE=$BUILD_MODE"

# Set the working directory
WORKDIR /workdir

# Install build dependencies and Poetry
RUN apt-get update && apt-get install -y build-essential
RUN pip install poetry

# Copy only the Poetry files to leverage Docker cache:
COPY pyproject.toml poetry.lock /workdir/

# Install project dependencies using Poetry
ENV POETRY_VIRTUALENVS_CREATE=false
RUN if [ "$BUILD_MODE" = "development" ]; then poetry install --no-interaction --no-cache; else poetry install --no-interaction --no-cache --no-dev; fi


FROM python:3.12.5-slim-bookworm

# Set the environment mode to production by default
ARG BUILD_MODE=production
RUN echo "BUILD_MODE=$BUILD_MODE"

# Set the working directory
WORKDIR /workdir

# Copy only necessary files from the builder stage (dependencies and the application code)
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY pyproject.toml poetry.lock /workdir/
COPY app /workdir/app

# Copy tests only if the environment is development
COPY tests /tmp/tests
RUN if [ "$BUILD_MODE" = "development" ]; then cp -r /tmp/tests /workdir/tests; fi
RUN rm -rf /tmp/tests

# Create a user to run the container
RUN useradd -m fastapi
RUN chown -R fastapi:fastapi /workdir
RUN chown -R fastapi:fastapi /usr/local/lib/python3.12/site-packages
RUN chown -R fastapi:fastapi /usr/local/bin
USER fastapi

EXPOSE 8000

# Run the application. Ensure hot reload if the environment is development
CMD if [ "$BUILD_MODE" = "development" ]; then \
        uvicorn app.app:app --host 0.0.0.0 --port 8000 --reload; \
    else \
        gunicorn app.app:app \
        --bind 0.0.0.0:8000 \
        --worker-class uvicorn.workers.UvicornWorker \
        --timeout 600; \
    fi
