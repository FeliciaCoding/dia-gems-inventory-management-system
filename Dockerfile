# syntax=docker/dockerfile:1
FROM python:3.13-slim AS build

COPY --from=ghcr.io/astral-sh/uv:0.8.21 /uv /uvx /bin/

WORKDIR /app

# UV_COMPILE_BYTECODE=1: Tells uv to compile Python files to bytecode for faster startup
# UV_LINK_MODE=copy: Ensures uv copies files instead of creating symlinks
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_NO_MANAGED_PYTHON=1 UV_PYTHON=/usr/local/bin/python

COPY uv.lock pyproject.toml ./

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-install-project --no-dev

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev



FROM python:3.13-slim AS runtime

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH="/app/src"

RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m -d /app -s /bin/false appuser

WORKDIR /app

COPY --from=build --chown=appuser:appgroup /app .

USER appuser

# Ensure .streamlit exists
RUN mkdir -p .streamlit

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "src/diamonds_ui/app.py", "--server.port=8501", "--server.address=0.0.0.0"]