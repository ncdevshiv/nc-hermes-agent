# Stage 1: Build the native SBCL binary
FROM debian:bookworm-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y sbcl curl make git ca-certificates

# Setup Quicklisp
RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    cat << 'QLEOF' > install-ql.lisp
(load "quicklisp.lisp")
(quicklisp-quickstart:install)
(ql:add-to-init-file)
(quit)
QLEOF
RUN sbcl --no-userinit --no-sysinit --load install-ql.lisp < /dev/null

WORKDIR /app
COPY . /app

# Run the build script
RUN ./build.sh

# Stage 2: Minimal runtime environment
FROM debian:bookworm-slim

# Install runtime dependencies for the Lisp image (like OpenSSL for Dexador)
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the generated standalone executable
COPY --from=builder /app/bin/hermes-agent /usr/local/bin/hermes-agent
COPY config.example.lisp /app/config.example.lisp

ENV HERMES_CONFIG="/app/config.example.lisp"

# Expose Gateway Port
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/hermes-agent"]
