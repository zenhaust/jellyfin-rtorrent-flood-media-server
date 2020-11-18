#ARG NODE_IMAGE=node:12.2-alpine
ARG NODE_IMAGE=node:15.2.1-alpine3.10
ARG WORKDIR=/usr/src/app/
ARG UGID=1100

FROM ${NODE_IMAGE} as nodebuild
ARG WORKDIR

WORKDIR $WORKDIR

ENV \
	FLOOD_GIT_URI=https://github.com/zenhaust/flood.git

RUN \
	apk add -U --no-cache git python mediainfo build-base && \
	mkdir -p /usr/src/app && \
	git clone $FLOOD_GIT_URI /usr/src/app

COPY config/config.js /usr/src/app/config.js

# RUN \
# 	npm install && \
#     npm audit fix && \
#     npm fund && \
# 	npm run build 
RUN \
	npm install && \
	npm run build 


FROM ${NODE_IMAGE}
WORKDIR /usr/src/app
ARG UGID

COPY --from=nodebuild /usr/src/app /usr/src/app

RUN \
    addgroup -g $UGID flood && \
    adduser -S -u $UGID -G flood flood && \
    chown -R flood:flood /usr/src/app && \
    apk add -U --no-cache mediainfo


USER flood



CMD [ "npm", "run", "start" ]
