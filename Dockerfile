FROM fedora:42

EXPOSE 80

COPY install.sh /
RUN /install.sh

COPY entrypoint.sh /
ENTRYPOINT ["sh","/entrypoint.sh"]