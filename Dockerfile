FROM node:24.11.0-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends dumb-init git ca-certificates

ENV NODE_ENV=production

RUN useradd -m -s /bin/bash reelyactive
USER reelyactive

WORKDIR /home/reelyactive/pareto-anywhere
COPY --chown=reelyactive . /home/reelyactive/pareto-anywhere

# Include Pareto Apps
RUN rm -rf web/apps && mkdir -p web/apps && \
    git -C web/apps init && \
    git -C web/apps fetch --depth=1 https://github.com/reelyactive/pareto-anywhere-apps.git bb052b36a919e5482b7c23c0905a3cc978b5b318 && \
    git -C web/apps checkout --detach FETCH_HEAD && \
    rm -rf web/apps/.git && \
    test -f web/apps/index.html

RUN npm install --omit=dev

RUN mkdir -p data/images data/records && \
    mkdir -p data/associations data/features data/stories && \
    touch data/associations/LOCK data/features/LOCK data/stories/LOCK

EXPOSE 3001/tcp 50000/udp 50001/udp

CMD ["dumb-init","node","bin/pareto-anywhere"]
