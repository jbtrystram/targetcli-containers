FROM quay.io/centos/centos:stream9

COPY saveconfig.json /etc/target/saveconfig.json

RUN dnf install -y targetcli kmod && dnf clean all
RUN systemctl enable target

EXPOSE 3260

CMD [ "/sbin/init" ]
