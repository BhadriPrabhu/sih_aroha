# Multi-stage Dockerfile for AROHA C++ Drogon Facility Server

# --- Build Stage ---
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install C++ build tools, CMake, SQLite3, and Drogon dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libsqlite3-dev \
    jsoncpp-dev \
    uuid-dev \
    zlib1g-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Drogon framework
RUN git clone --recursive https://github.com/drogonframework/drogon.git /tmp/drogon && \
    cd /tmp/drogon && \
    mkdir build && cd build && \
    cmake .. -BUILD_DROGON_CLI=OFF && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/drogon

# Copy C++ source files
WORKDIR /app
COPY . .

# Build C++ Drogon Facility Server executable
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

# --- Runtime Stage ---
FROM ubuntu:22.04 AS runner

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    jsoncpp-dev \
    libssl3 \
    zlib1g \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled executable and config/migrations from builder
COPY --from=builder /app/build/aroha_facility_server ./aroha_facility_server
COPY --from=builder /app/config ./config
COPY --from=builder /app/db ./db

EXPOSE 8080

CMD ["./aroha_facility_server"]
