FROM amazonlinux:latest

RUN yum install -y shadow-utils util-linux awscli jq && yum clean all

RUN useradd --uid 2566 --create-home --home-dir /opt/sysdig sysdig
COPY files/scan.sh /opt/sysdig/scan.sh
RUN chown sysdig /opt/sysdig && chown sysdig /opt/sysdig/scan.sh && chmod 775 /opt/sysdig/scan.sh

ENTRYPOINT ["/opt/sysdig/scan.sh"]