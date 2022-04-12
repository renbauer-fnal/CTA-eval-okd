# [renbauer] This is basically the buildtree base image, cleaned up a bit

FROM gitlab-registry.cern.ch/linuxsupport/cc7-base

# my environment variables
ENV BASEDIR="."

# yum update could be added at some point.
RUN yum install -y wget \
  && yum update -y \
  && yum clean all

# Add repos for CTA dependencies
ADD ${BASEDIR}/etc/logrotate.d /etc/logrotate.d
ADD ${BASEDIR}/etc/yum /etc/yum
ADD ${BASEDIR}/etc/yum.repos.d-public /etc/yum.repos.d

SHELL ["/bin/bash", "-c"]

# TODO [renbauer]: This expects a cta-repo to be running on the build host already.
# This can be done with:
# $ docker run -it -p 8000:8000 imageregistry.fnal.gov/cta-eval/cta-easy-repo
# Then, run `docker build --network host` to allow build container access to port
# There might be a better way, but adding the rpms here directly might cause a lot of bloat.
ARG cta_repo_addr=localhost:8000

ENV cta_repo_addr $cta_repo_addr

RUN echo $'[cta-repo] \n\
name=CTA Repo \n\
baseurl=http://'$cta_repo_addr$'/packages \n\
enabled=0 \n\
gpgcheck=1 \n\
gpgkey=http://'$cta_repo_addr$'/pgp-key.public' > /etc/yum.repos.d/cta-repo.repo

RUN wget https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol7 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
RUN wget https://git.ceph.com/release.asc -O /etc/pki/rpm-gpg/RPM-ASC-KEY-ceph
RUN wget http://$cta_repo_addr/pgp-key.public -O /etc/pki/rpm-gpg/RPM-GPG-KEY-cta-repo

RUN yum clean all

RUN yum install -y \
      yum-plugin-downloadonly \
      yum-plugin-priorities \
      yum-plugin-versionlock \
      createrepo epel-release \
  && \
    yum clean all

# TODO [renbauer] we should only yum install the necessary rpms for all containers, but
# I don't know what those are yet..
# This is an alphabetized list from buildtree-stage1-rpms-local/Dockerfile

# Populate local repository and enable it, then install any rpm that is needed for
# any container. Finally add needed directories.
RUN yum-config-manager --enable epel --setopt="epel.priority=4" \
  && \
    yum install -y \
      ceph-common \
      cgdb \
      cryptopp \
      eos-folly \
      gtest \
      heimdal-server \
      heimdal-workstation \
      hiredis \
      jemalloc \
      jq \
      json-c \
      jsoncpp \
      less \
      libmicrohttpd \
      logrotate \
      lsscsi \
      ltrace \
      lynx \
      mariadb-devel \
      mt-st \
      mtx \
      oracle-instantclient19.3-basic \
      oracle-instantclient19.3-meta \
      oracle-instantclient19.3-sqlplus \
      postgresql-libs \
      protobuf3 \
      psmisc \
      python36 \
      sg3_utils \
      shadow-utils \
      strace \
      sudo \
      xrootd \
      xrootd-client \
      xrootd-debuginfo \
      xrootd-server \
      zeromq \
  && \
    yum clean all \
  && \
    rm -rf /var/cache/yum \
  && \
    mkdir -pv /etc/cta

# Install additional CTA RPM dependencies
RUN yum -y install eos-client grpc valgrind make moreutils

# Install CTA RPMs (except migration tools)
RUN yum install -y --disablerepo="*" --enablerepo="cta-repo" cta-catalogueutils cta-cli cta-common cta-debuginfo cta-frontend cta-fst-gcd cta-immutable-file-test cta-lib-catalogue cta-objectstore-tools cta-readtp cta-release cta-rmcd cta-smc cta-systemtest-helpers cta-systemtests cta-tape-label cta-taped

CMD sleep infinity
