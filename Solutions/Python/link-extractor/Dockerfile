FROM python:3.11-slim AS base
WORKDIR /app
COPY . /app
RUN pip install -e .

FROM python:3.11-alpine
WORKDIR /app
COPY --from=base /usr/local/lib/python3.11 /usr/local/lib/python3.11
ENTRYPOINT ["python", "-m", "link-extractor"]
CMD []
