FROM httpd:2.4
LABEL maintainer="sebastian@sommerfeld.io"

RUN rm /usr/local/apache2/htdocs/tech-radar.html
COPY ./target/docs/public /usr/local/apache2/htdocs
COPY ./target/docs-deprecated/public /usr/local/apache2/htdocs/docs-deprecated
