FROM centos:centos7.9.2009 AS builder

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ARG oracle_database_version=10.2.0
ARG resource_bucket_name
ARG tuxedo_version=8.1

RUN yum install -y unzip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install

RUN mkdir -p /opt/tuxedo/${tuxedo_version} \
    && aws s3 cp s3://${resource_bucket_name}/packages/tuxedo/tuxedo-${tuxedo_version}.tar.gz . \
    && tar -xvzf tuxedo-${tuxedo_version}.tar.gz -C /opt/tuxedo/${tuxedo_version} \
    && chown -R root:root /opt/tuxedo/${tuxedo_version}

RUN mkdir -p /opt/oracle/${oracle_database_version} \
    && aws s3 cp s3://${resource_bucket_name}/packages/oracle/oracle-database-${oracle_database_version}.tar.gz . \
    && tar -xvzf oracle-database-${oracle_database_version}.tar.gz -C /opt/oracle/${oracle_database_version} \
    && chown -R root:root /opt/tuxedo/${tuxedo_version}

RUN aws s3 cp s3://${resource_bucket_name}/libraries/c/i686/libstdc++-libc6.2-2.so.3 /usr/lib \
    && chmod 755 /usr/lib/libstdc++-libc6.2-2.so.3

FROM centos:centos7.9.2009

COPY --from=builder /opt/tuxedo /opt/tuxedo
COPY --from=builder /opt/oracle /opt/oracle
COPY --from=builder /usr/lib/libstdc++-libc6.2-2.so.3 /usr/lib/libstdc++-libc6.2-2.so.3

RUN yum groupinstall -y 'Development Tools'

RUN yum install -y \
    cyrus-sasl-devel.i686 \
    expat-devel.i686 \
    glibc-devel.i686 \
    glibc-static.i686 \
    libcurl-devel.i686 \
    ncurses-devel.i686 \
    net-snmp-devel.i686 \
    openssl-devel.i686 \
    readline-devel.i686 \
    && yum clean all

ENV LANG=C
ENV TUXDIR=/opt/tuxedo/${tuxedo_version}
ENV PATH=/opt/tuxedo/${tuxedo_version}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include:/opt/oracle/${oracle_database_version}/lib:/opt/tuxedo/${tuxedo_version}/lib
ENV ORACLE_HOME=/opt/oracle/${oracle_database_version}
