ARG VERSION=minimal
FROM octoprint/octoprint:${VERSION}

COPY plugins.txt /tmp/plugins.txt
RUN pip install -r /tmp/plugins.txt
