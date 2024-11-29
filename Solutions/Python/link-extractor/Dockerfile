ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

FROM python:3.11-slim AS builder

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="lucshelton/link-extractor/python-builder" \
      org.label-schema.version="${BUILD_VERSION}" \
      org.label-schema.description="Builder stage for link-extractor Python application"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl build-essential gcc libffi-dev && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:$PATH"

# Copy dependency files first to leverage caching
# COPY pyproject.toml poetry.lock ./
COPY . .

# # Export non-dev dependencies to requirements.txt
# RUN poetry export --without-hashes --without dev -o requirements.txt

# # Install non-dev dependencies
# RUN pip install --no-cache-dir -r requirements.txt

# Build the package
RUN poetry build --format wheel

# Copy the entire application

# Install the built wheel package
RUN pip install --no-cache-dir dist/*.whl

FROM python:3.11-slim

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="lucshelton/link-extractor/python-runtime" \
      org.label-schema.version="${BUILD_VERSION}" \
      org.label-schema.description="Runtime stage for link-extractor Python application"

WORKDIR /app

COPY --from=builder /usr/local /usr/local
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

ENV PATH="/usr/local/bin:/root/.local/bin:$PATH"

ENTRYPOINT ["link-extractor"]
