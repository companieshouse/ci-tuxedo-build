FROM centos:centos7.9.2009 AS builder

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ARG informix_sdk_version
ARG oracle_database_version
ARG oracle_instant_client_version
ARG resource_bucket_name
ARG tuxedo_version

RUN yum install -y unzip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install

RUN mkdir -p /opt/tuxedo/${tuxedo_version} \
    && aws s3 cp s3://${resource_bucket_name}/tuxedo/tuxedo-${tuxedo_version}.tar.gz . \
    && tar -xvzf tuxedo-${tuxedo_version}.tar.gz -C /opt/tuxedo/${tuxedo_version} \
    && chown -R root:root /opt/tuxedo/${tuxedo_version}

RUN mkdir -p /opt/oracle/${oracle_database_version} \
    && aws s3 cp s3://${resource_bucket_name}/oracle/oracle-database-${oracle_database_version}.tar.gz . \
    && tar -xvzf oracle-database-${oracle_database_version}.tar.gz -C /opt/oracle/${oracle_database_version} \
    && chown -R root:root /opt/tuxedo/${tuxedo_version}

RUN mkdir -p /opt/oracle-instant-client/${oracle_instant_client_version} \
    && for package_name in basic precomp sdk; do \
        aws s3 cp s3://${resource_bucket_name}/oracle/instantclient-${package_name}-linux-${oracle_instant_client_version}.zip . ; \
        unzip -d /opt/oracle-instant-client/${oracle_instant_client_version} instantclient-${package_name}-linux-${oracle_instant_client_version}.zip; \
        rm -f instantclient-${package_name}-linux-${oracle_instant_client_version}.zip; \
    done \
    && chown -R root:root /opt/oracle-instant-client/${oracle_instant_client_version}

RUN mkdir -p /opt/informix-client-sdk/${informix_sdk_version} \
    && aws s3 cp s3://${resource_bucket_name}/informix/informix-sdk-${informix_sdk_version}.tar.gz . \
    && tar -xvzf informix-sdk-${informix_sdk_version}.tar.gz -C /opt/informix-client-sdk/${informix_sdk_version} \
    && chown -R root:root /opt/informix-client-sdk/${informix_sdk_version}

RUN aws s3 cp s3://${resource_bucket_name}/libraries/c/i686/libstdc++-libc6.2-2.so.3 /usr/lib \
    && chmod 755 /usr/lib/libstdc++-libc6.2-2.so.3

RUN aws s3 cp s3://${resource_bucket_name}/licenses/tuxedo/tuxedo-${tuxedo_version} /opt/tuxedo/${tuxedo_version}/udataobj/lic.txt \
    && chmod 755 /opt/tuxedo/${tuxedo_version}/udataobj/lic.txt

FROM centos:centos7.9.2009

ARG informix_sdk_version
ARG oracle_database_version
ARG oracle_instant_client_version
ARG tuxedo_version
ARG yum_repository_url

COPY --from=builder /opt/tuxedo /opt/tuxedo
COPY --from=builder /opt/oracle /opt/oracle
COPY --from=builder /opt/informix-client-sdk /opt/informix-client-sdk
COPY --from=builder /opt/oracle-instant-client /opt/oracle-instant-client
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
    libaio-devel.i686 \
    && yum clean all

RUN rpm --import http://${yum_repository_url}/RPM-GPG-KEY-platform-noarch \
    && yum install -y yum-utils \
    && yum-config-manager --add-repo http://${yum_repository_url}/platform-noarch.repo \
    && yum install -y platform-tools-common-1.0.6 \
    && yum clean all

COPY pcscfg.cfg /opt/oracle-instant-client/${oracle_instant_client_version}/precomp/admin/pcscfg.cfg

RUN ln -s /opt/oracle-instant-client/${oracle_instant_client_version}/libclntsh.so.11.1 /opt/oracle-instant-client/${oracle_instant_client_version}/libclntsh.so

RUN mkdir -p /opt/oracle-instant-client/${oracle_instant_client_version}/network/admin

COPY tnsnames.ora /opt/oracle-instant-client/${oracle_instant_client_version}/network/admin/tnsnames.ora

ENV LANG=C
ENV TUXDIR=/opt/tuxedo/${tuxedo_version}
ENV PATH=/opt/tuxedo/${tuxedo_version}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include:/opt/oracle/${oracle_database_version}/lib:/opt/tuxedo/${tuxedo_version}/lib
ENV ORACLE_HOME=/opt/oracle/${oracle_database_version}
ENV INFORMIXDIR=/opt/informix-client-sdk/${informix_sdk_version}
