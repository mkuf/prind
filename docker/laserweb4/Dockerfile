FROM --platform=$BUILDPLATFORM node:22-bookworm AS build

RUN git clone https://github.com/ssendev/LaserWeb4 /opt/laserweb \
&& cd /opt/laserweb \
&& git checkout v4.1 \
&& git submodule init \
&& git submodule update

WORKDIR /opt/laserweb
RUN npm ci --force
RUN npm run bundle-prod

FROM nginx:alpine as frontend

COPY --from=build /opt/laserweb/dist /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html