# ---- build stage: install dependencies into a virtualenv ----
FROM python:3.13-slim AS build
WORKDIR /app
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- runtime stage: only the venv + code, runs as non-root ----
FROM python:3.13-slim
RUN useradd --system --uid 10001 --no-create-home app
COPY --from=build /venv /venv
ENV PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
COPY main.py .
USER 10001
EXPOSE 8080
# exec form -> uvicorn is PID 1 and receives SIGTERM for graceful shutdown
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
