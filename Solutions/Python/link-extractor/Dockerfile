ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

FROM python:3.11-slim AS base

ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.name="lucshelton/link-extractor/python" \
    org.label-schema.url="https://www.lucshelton.com" \
    org.label-schema.description="${BUILD_UID}" \
    org.label-schema.version="${BUILD_VERSION}"

WORKDIR /app
COPY . /app
RUN pip install .

FROM python:3.11-alpine

ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.name="lucshelton/link-extractor/python" \
    org.label-schema.url="https://www.lucshelton.com" \
    org.label-schema.description="${BUILD_UID}" \
    org.label-schema.version="${BUILD_VERSION}"

WORKDIR /app
RUN apk add --no-cache bash nano libffi-dev gcc musl-dev
COPY --from=base /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=base /app /app
RUN pip install .
ENTRYPOINT ["link-extractor"]
CMD []
