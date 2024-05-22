FROM ghcr.io/inblockio/mediawiki-extensions-aqua:main
RUN apt update && apt install wget
COPY delme.sh .
RUN ls
RUN chmod +x delme.sh
RUN ./delme.sh
RUN rm ./delme.sh