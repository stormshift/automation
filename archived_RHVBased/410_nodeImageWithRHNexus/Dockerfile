FROM registry.access.redhat.com/rhscl/nodejs-10-rhel7
USER root
RUN mkdir -p /opt/app-root/src/
COPY ./RH-IT-Root-CA.crt /opt/app-root/src/
COPY ./npmrc /opt/app-root/src/.npmrc
RUN chgrp -R 0 /opt/app-root/src/ && chmod -R g=u /opt/app-root/src/
USER 1001
