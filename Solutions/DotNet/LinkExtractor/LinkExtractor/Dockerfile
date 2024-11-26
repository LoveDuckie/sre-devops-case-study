ARG BUILD_TYPE=development
ARG BUILD_CONFIGURATION=Debug
ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base

ARG BUILD_TYPE=development
ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

LABEL maintainer="Luc Shelton <lucshelton@gmail.com>"

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.name="lucshelton/link-extractor/dotnet" \
    org.label-schema.url="https://www.lucshelton.com" \
    org.label-schema.description="${BUILD_UID}" \
    org.label-schema.version="${BUILD_VERSION}"

USER $APP_UID
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG BUILD_TYPE=development
ARG BUILD_VERSION=1.0
ARG BUILD_UID
ARG BUILD_DATE

LABEL maintainer="Luc Shelton <lucshelton@gmail.com>"

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.name="lucshelton/link-extractor/dotnet" \
    org.label-schema.url="https://www.lucshelton.com" \
    org.label-schema.description="${BUILD_UID}" \
    org.label-schema.version="${BUILD_VERSION}"

ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["LinkExtractor/LinkExtractor.csproj", "LinkExtractor/"]
RUN dotnet restore "LinkExtractor/LinkExtractor.csproj"
COPY . .
WORKDIR "/src/LinkExtractor"
RUN dotnet build "LinkExtractor.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "LinkExtractor.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LinkExtractor.dll"]
