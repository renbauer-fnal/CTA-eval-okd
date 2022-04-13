# Base pod image with logic from /opt/run/bin/client.sh

FROM imageregistry.fnal.gov/cta-eval/base-pod-image

RUN yum-config-manager --enable ceph

# Not sure why this is suddenly needed here..
RUN yum-config-manager --disable cta

# Install missing RPMs (these are actually all installed already)
RUN yum -y install \
     eos-client \
     jq \
     python36 \
     xrootd-client

# The following are installed in base image (for now)
     # cta-cli \
     # cta-debuginfo \
     # cta-immutable-file-test \
     # cta-systemtest-helpers \

ADD cta-cli.conf /etc/cta/cta-cli.conf

# Inherit CMD from parent
# CMD ~/init_script.sh && sleep infinity
