FROM httpd:2.4
LABEL maintainer="sebastian@sommerfeld.io"

RUN rm /usr/local/apache2/htdocs/index.html
COPY ./src/main/tech-radar /usr/local/apache2/htdocs
