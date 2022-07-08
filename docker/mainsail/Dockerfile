## Get Code and build App
FROM --platform=$BUILDPLATFORM node:16 as build

ARG REPO=https://github.com/mainsail-crew/mainsail
ARG VERSION=develop

RUN git clone ${REPO} /opt/mainsail \
 && cd /opt/mainsail \
 && git checkout ${VERSION}

WORKDIR /opt/mainsail
RUN npm install \
 && ./node_modules/vite/bin/vite.js build

## Runtime Image
FROM nginx:alpine as run

COPY --from=build /opt/mainsail/dist /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
