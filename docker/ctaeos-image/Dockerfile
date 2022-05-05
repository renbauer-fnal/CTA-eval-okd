# Base eos pod image + logic from /opt/run/bin/ctaeos-mgm.sh

FROM imageregistry.fnal.gov/cta-eval/base-eos-pod-image:latest

# We have cta and eos rpms from base image

# Add pod specific configuration
ADD data/config /opt/ci

# Check that the /usr/bin/cta-fst-gcd executable has been installed in init script
RUN test -e /usr/bin/cta-fst-gcd || \
        { echo "/usr/bin/cta-fst-gcd MISSING" ; exit 1; } && \
    test -f /usr/bin/cta-fst-gcd || \
        { echo "/usr/bin/cta-fst-gcd NO A REGULAR FILE"; exit 1; } && \
    test -x /usr/bin/cta-fst-gcd && echo "/usr/bin/cta-fst-gcd exists as a regular, executable file: OK" || \
        { echo "/usr/bin/cta-fst-gcd NOT EXECUTABLE"; exit 1; }

# create local users as the mgm is the only one doing the uid/user/group mapping in the full infrastructure
RUN groupadd --gid 1100 eosusers && \
    groupadd --gid 1200 powerusers && \
    groupadd --gid 1300 ctaadmins && \
    groupadd --gid 1400 eosadmins && \
    useradd --uid 11001 --gid 1100 user1 && \
    useradd --uid 11002 --gid 1100 user2 && \
    useradd --uid 12001 --gid 1200 poweruser1 && \
    useradd --uid 12002 --gid 1200 poweruser2 && \
    useradd --uid 13001 --gid 1300 ctaadmin1 && \
    useradd --uid 13002 --gid 1300 ctaadmin2 && \
    useradd --uid 14001 --gid 1400 eosadmin1 && \
    useradd --uid 14002 --gid 1400 eosadmin2

# copy needed template configuration files
RUN cp -r /opt/ci/ctaeos/etc /

# Set permissions for files touched by init script
RUN chgrp -R 0 /etc/sysconfig && \
    chmod -R g=u /etc/sysconfig
RUN chgrp -R 0 /etc && \
    chmod -R g=u /etc
RUN chgrp -R 0 /var/eos && \
    chmod -R g=u var/eos
RUN mkdir -p /var/eos/auth && \
    chgrp -R 0 /var/eos/auth && \
    chmod -R g=u var/eos/auth
RUN mkdir -p /var/eos/md && \
    chgrp -R 0 /var/eos/md && \
    chmod -R g=u var/eos/md
RUN mkdir -p /var/eos/config && \
    chgrp -R 0 /var/eos/config && \
    chmod -R g=u var/eos/config
RUN mkdir -p /var/log/eos && \
    chgrp -R 0 /var/log/eos && \
    chmod -R g=u /var/log/eos
RUN mkdir /var/eos/config/host && \
    chown daemon:root /var/eos/config && \
    chown daemon:root /var/eos/config/host

# Add init script containing logic that can't be performed at build,
# append to init script inherited from parent images
ADD data/init.sh /tmp/eosmgm_init.sh
RUN cat /tmp/eosmgm_init.sh >> /etc/init_script.sh

# Add this for SSI prococol buffer workflow (xrootd >=4.8.2)
RUN echo "mgmofs.protowfendpoint ctafrontend:10955" >> /etc/xrd.cf.mgm
RUN echo "mgmofs.protowfresource /ctafrontend"  >> /etc/xrd.cf.mgm

# Enable tape support
RUN echo "mgmofs.tapeenabled true"  >> /etc/xrd.cf.mgm

# Add this for SSI protocol buffer workflow (xrootd >=4.8.2)
RUN echo "mgmofs.protowfendpoint ctafrontend:10955" >> /etc/xrd.cf.mgm && \
    echo "mgmofs.protowfresource /ctafrontend"  >> /etc/xrd.cf.mgm

# Add configmap based configuration (initially Namespace)
# TODO: /etc/config/eos/xrd.cf.mgm comes from a configmap which is not yet implemented. For now we cheat** which may be okay if we don't need to configure this for our environment.
# test -f /etc/config/eos/xrd.cf.mgm && cat /etc/config/eos/xrd.cf.mgm >> /etc/xrd.cf.mgm
RUN echo "mgmofs.nslib /usr/lib64/libEosNsInMemory.so" >> /etc/xrd.cf.mgm

# prepare eos startup
  # skip systemd for eos initscripts
ENV SYSTEMCTL_SKIP_REDIRECT=1

# TODO: reimplement authentication
# Openshift containers run as an unknown user, so keytab cannot be set to
# that particular user, and if permissions are not 400 xrootd fails with
# keytab not secure.
# To get around, all security options are currently commented out of xrd
# config files (currently under base-pod but maybe should be here).
# 
#  echo y | xrdsssadmin -k ${EOS_INSTANCE}+ -u daemon -g daemon add /etc/eos.keytab
# need a deterministic key for taped and it must be forwardable in case of kubernetes
# see [here](http://xrootd.org/doc/dev47/sec_config.htm#_Toc489606587)
# can only have one key????
# RUN echo -n '0 u:daemon g:daemon n:ctaeos+ N:6361884315374059521 c:1481241620 e:0 f:0 k:1a08f769e9c8e0c4c5a7e673247c8561cd23a0e7d8eee75e4a543f2d2dd3fd22' > /etc/eos.keytab && \
  # chmod 400 /etc/eos.keytab && \
  # chown daemon:daemon /etc/eos.keytab

RUN mkdir -p /run/lock/subsys
# This file is owned by daemon:daemon in original script, but in
# order to be moved to /var/eos/config/{eoshost}
# by init script it must be owned by group root, because
# the container user is in root group but not daemon group
RUN touch /var/eos/config/host/default.eoscf && \
    chgrp -R 0 /var/eos/config/host && \
    chmod -R g=u var/eos/config/host && \
    chown daemon:root /var/eos/config/host/default.eoscf

# Configure mq mgm on localhost as master
RUN touch /var/eos/eos.mq.master && \
    touch /var/eos/eos.mgm.rw

RUN mkdir -p /fst && \
    chown daemon:daemon /fst/

# setting higher OS limits for EOS processes
RUN maxproc=$(ulimit -u) && \
    echo "daemon soft nproc ${maxproc}" >> /etc/security/limits.conf && \
    echo "daemon hard nproc ${maxproc}" >> /etc/security/limits.conf

# Overwrite command for testing
# CMD sleep infinity

# Set env vars per no systemd
ENV LD_PRELOAD=/usr/lib64/libjemalloc.so.1
ENV XRDPROG=/opt/eos/xrootd/bin/xrootd

# TODO: Limit this to only necessary commands
# TODO (cleanup): This doesn't seem to do anything, can't run sudo anyway because we get "unknown user"
# RUN echo "# Allow members of group root to run any command anywhere" >> /etc/sudoers
# RUN echo "# (this includes the container user)" >> /etc/sudoers
# RUN echo "%root   ALL=(ALL)       ALL" >> /etc/sudoers

# Try to give container user permissions to run xrootd as another group
# RUN chmod g+s /opt/eos/xrootd/bin/*
