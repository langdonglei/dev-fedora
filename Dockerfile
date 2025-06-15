FROM fedora:40

EXPOSE 80

COPY ./install.sh /install.sh
RUN sh /install.sh

COPY entrypoint.sh /
ENTRYPOINT ["sh","/entrypoint.sh"]