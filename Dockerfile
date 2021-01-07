FROM centos:centos7.9.2009

# TODO remove sensitive build arguments below to ensure that these
# cannot be retrieved from the image history

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ARG oracle_database_version=10.2.0
ARG resource_bucket_name
ARG tuxedo_version=8.1

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

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws && \
    rm -f awscliv2.zip

RUN mkdir -p /opt/tuxedo/${tuxedo_version} \
    && tmp_dir=$(mktemp -d /tmp/tuxedo.XXX) \
    && aws s3 cp s3://${resource_bucket_name}/packages/tuxedo/tuxedo-${tuxedo_version}.tar.gz ${tmp_dir} \
    && tar -xvzf ${tmp_dir}/tuxedo-${tuxedo_version}.tar.gz -C /opt/tuxedo/${tuxedo_version}/ \
    && rm -rf ${tmp_dir} \
    && chown -R root:root /opt/tuxedo/${tuxedo_version}

RUN mkdir -p /opt/oracle/${oracle_database_version} \
    && tmp_dir=$(mktemp -d /tmp/oracle.XXX) \
    && aws s3 cp s3://r${resource_bucket_name}/packages/oracle/oracle-database-${oracle_database_version}.tar.gz ${tmp_dir} \
    && tar -xvzf ${tmp_dir}/oracle-database-${oracle_database_version}.tar.gz -C /opt/oracle/${oracle_database_version} \
    && rm -rf ${tmp_dir} \
    && chown -R root:root /opt/oracle/${oracle_database_version}

RUN aws s3 cp s3://${resource_bucket_name}/libraries/c/i686/libstdc++-libc6.2-2.so.3 /usr/lib \
    && chmod 755 /usr/lib/libstdc++-libc6.2-2.so.3
