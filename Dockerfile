FROM busybox:latest

COPY config /opt/printer_data/config
COPY config/octoprint.yaml /octoprint/octoprint/config.yaml
RUN chown -R 1000:1000 /opt/printer_data/config
