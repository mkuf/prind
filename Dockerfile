FROM busybox:latest

COPY config /opt/printer_data/config
RUN chown -R 1000:1000 /opt/printer_data/config
