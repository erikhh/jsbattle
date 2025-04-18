FROM node:lts-alpine

RUN apk add --no-cache \
        chromium \
        python3 \
        make \
        g++ \
        gcc \
        cairo-dev \
        jpeg-dev \
        pango-dev \
        giflib-dev \
        pixman-dev \
        pangomm-dev \
        libjpeg-turbo-dev\
        freetype-dev \
        pixman \
        cairo \
        pango \
        giflib \
        openjdk17-jdk

WORKDIR /app
COPY package.json lerna.json ./
COPY packages/jsbattle/package.json ./packages/jsbattle/package.json
COPY packages/jsbattle-admin/package.json ./packages/jsbattle-admin/package.json
COPY packages/jsbattle-docs/package.json ./packages/jsbattle-docs/package.json
COPY packages/jsbattle-engine/package.json ./packages/jsbattle-engine/package.json
COPY packages/jsbattle-mockserver/package.json ./packages/jsbattle-mockserver/package.json
COPY packages/jsbattle-react/package.json ./packages/jsbattle-react/package.json
COPY packages/jsbattle-server/package.json ./packages/jsbattle-server/package.json
RUN npm install

COPY . .
ENV NODE_ENV=production
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser 
RUN npm run build \
    && mkdir -p ./dist/public \
    && cp -Rv ./node_modules/jsbattle-admin/dist/* ./dist/public/ \
    && cp -Rv ./node_modules/jsbattle-webpage/dist/* ./dist/public/ \
    && cp -Rv ./node_modules/jsbattle/src/* ./dist/ \
    && addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app

EXPOSE 8080
USER appuser
ENTRYPOINT [ "node", "dist/jsbattle.js", "start", "--config", "./jsbattle.config.json" ]
