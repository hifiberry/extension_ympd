FROM debian:stable as builder

# Set up build dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y build-essential git pkg-config libasound2-dev libmpdclient-dev libssl-dev cmake

WORKDIR /app

RUN git clone https://github.com/SuperBFG7/ympd

# Compile the source code
RUN cd ympd  && \
    mkdir build  && \
    cd build && \
    cmake ..  -DCMAKE_INSTALL_PREFIX:PATH=/usr/local && \
    make && \
    make install

# Create a new image
FROM debian:stable-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends libmpdclient2 libssl3 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -g 9999 -r ympd && \
    useradd --no-log-init -r -g ympd -u 9999 ympd 

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/local/bin/ympd /usr/local/bin/ympd

# Set working directory
WORKDIR /usr/local/bin

# Run spotifyd
CMD ["ympd", "-h" , "172.17.0.1", "-w", "0.0.0.0:9999"]

EXPOSE 9999

USER ympd
