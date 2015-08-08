FROM blacklabelops/centos
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install tools
RUN yum install -y \
    epel-release && \
    yum clean all && rm -rf /var/cache/yum/*

# install dev tools
RUN yum install -y \
    wget \
    tar \
    unzip \
    supervisor \
    vi \
    cronie && \
    yum clean all && rm -rf /var/cache/yum/*

# install gcloud
ENV PATH /opt/google-cloud-sdk/bin:$PATH
RUN mkdir -p /opt/gcloud && \
    wget --no-check-certificate --directory-prefix=/tmp/ https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && \
    unzip /tmp/google-cloud-sdk.zip -d /opt/ && \
    /opt/google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/opt/gcloud/.bashrc --disable-installation-options && \
    gcloud --quiet components update app preview alpha beta app-engine-java app-engine-python kubectl bq core gsutil gcloud && \
    rm -rf /tmp/*

COPY imagescripts/docker-entrypoint.sh /opt/gcloud/docker-entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
COPY cron.ini /etc/supervisord.d/cron.ini
ENTRYPOINT ["/opt/gcloud/docker-entrypoint.sh"]
CMD ["supervisord"]
