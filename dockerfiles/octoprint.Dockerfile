ARG VERSION=minimal
FROM octoprint/octoprint:${VERSION}

RUN apt update \
 && apt install -y something \
 && apt clean

RUN pip install "https://github.com/OllisGit/OctoPrint-PrintJobHistory/releases/latest/download/master.zip" \
 && pip install "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/master.zip" \
 && pip install "https://github.com/OllisGit/OctoPrint-FilamentManager/releases/latest/download/master.zip" \
 && pip install "https://github.com/jneilliii/OctoPrint-PrusaSlicerThumbnails/archive/master.zip" \
 && pip install "https://github.com/thijsbekke/OctoPrint-Pushover/archive/master.zip" \
 && pip install "https://github.com/jneilliii/OctoPrint-TabOrder/archive/master.zip" \
 && pip install "https://github.com/1r0b1n0/OctoPrint-Tempsgraph/archive/master.zip" \
 && pip install "https://github.com/jneilliii/OctoPrint-TerminalCommandsExtended/archive/master.zip" \
 && pip install "https://github.com/birkbjo/OctoPrint-Themeify/archive/master.zip" \
 && pip install "https://github.com/BillyBlaze/OctoPrint-TouchUI/archive/master.zip" \
