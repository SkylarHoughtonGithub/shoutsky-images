FROM debian:bullseye-slim

# Install corosync-qnetd
RUN apt-get update && \
    apt-get install -y \
    corosync-qnetd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create qnetd user and directories  
RUN useradd -r -s /bin/false -d /var/lib/corosync qnetd && \
    mkdir -p /etc/corosync/qnetd && \
    chown -R qnetd:qnetd /etc/corosync

# Create startup script
RUN echo '#!/bin/bash\n\
# Initialize NSS database if it does not exist\n\
if [ ! -f /etc/corosync/qnetd/nssdb/cert9.db ]; then\n\
    echo "Initializing NSS database..."\n\
    corosync-qnetd-certutil -i\n\
fi\n\
\n\
# Start qnetd\n\
echo "Starting corosync-qnetd..."\n\
exec corosync-qnetd -f' > /start-qnetd.sh && \
    chmod +x /start-qnetd.sh

# Expose QDevice port
EXPOSE 5403

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -ln | grep :5403 || exit 1

# Start with our script
CMD ["/start-qnetd.sh"]