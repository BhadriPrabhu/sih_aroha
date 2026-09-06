# Dockerfile for AROHA C++ Drogon Facility Server

FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install C++ build tools, CMake, SQLite3, Jsoncpp, and Drogon dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libsqlite3-dev \
    libjsoncpp-dev \
    uuid-dev \
    zlib1g-dev \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Drogon framework v1.9.5
RUN git clone --depth 1 -b v1.9.5 --recursive https://github.com/drogonframework/drogon.git /tmp/drogon && \
    cd /tmp/drogon && \
    mkdir build && cd build && \
    cmake .. -DBUILD_DROGON_CLI=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/drogon

# Copy C++ source files
WORKDIR /app
COPY . .

# Build C++ Drogon Facility Server executable
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

EXPOSE 8080

CMD ["./build/aroha_facility_server"]
