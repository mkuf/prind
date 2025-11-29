FROM --platform=$BUILDPLATFORM node:22-bookworm AS build

ARG REPO=https://github.com/ssendev/LaserWeb4
ARG VERSION=v4.1

WORKDIR /opt
RUN git clone ${REPO} laserweb \
&& cd laserweb \
&& git checkout ${VERSION} \
&& git submodule init \
&& git submodule update

WORKDIR /opt/laserweb
RUN npm ci --force
RUN npm run bundle-prod

FROM nginx:alpine AS run

COPY --from=build /opt/laserweb/dist /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html