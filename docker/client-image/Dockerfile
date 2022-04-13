# Base pod image with logic from /opt/run/bin/client.sh

FROM imageregistry.fnal.gov/cta-eval/base-pod-image

RUN yum-config-manager --enable cta-artifacts \ 
    && yum-config-manager --enable ceph

  # Install missing RPMs
RUN yum -y install \
     cta-cli \
     cta-debuginfo \
     cta-immutable-file-test \
     cta-systemtest-helpers \
     eos-client \
     jq \
     python36 \
     xrootd-client

ADD cta-cli.conf /etc/cta/cta-cli.conf

# Inherit CMD from parent
# CMD ~/init_script.sh && sleep infinity
