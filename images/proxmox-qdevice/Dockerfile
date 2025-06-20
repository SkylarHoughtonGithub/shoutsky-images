FROM debian:bullseye-slim

# Install corosync-qnetd
RUN apt-get update && \
    apt-get install -y \
    corosync-qnetd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create qnetd user and directories
RUN useradd -r -s /bin/false -d /var/lib/corosync qnetd && \
    mkdir -p /etc/corosync/qnetd/nssdb && \
    chown -R qnetd:qnetd /etc/corosync

# Remove existing NSS database and initialize new one
RUN rm -rf /etc/corosync/qnetd/nssdb/* && \
    corosync-qnetd-certutil -i

# Expose QDevice port
EXPOSE 5403

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -ln | grep :5403 || exit 1

# Start qnetd
CMD ["corosync-qnetd", "-f"]