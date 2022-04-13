# Execute logic otherwise performed in init_pod.sh

FROM imageregistry.fnal.gov/cta-eval/cta-eval-okd-base-cta-image

RUN touch /var/log/cta-rados-locking.log \
    && ln -s /var/log/cta-rados-locking.log /var/tmp/cta-rados-locking.log

# Some commands require information (like hostname) not yet available.
# To accomodate such commands we will build an init_script inside the image,
# and use this script as the entrypoint for all images.
RUN touch /etc/init_script.sh
RUN chmod u+x /etc/init_script.sh

# Change permissions of /etc/hosts so it can be modified in init script
RUN chmod 666 /etc/hosts

# Fix reverse DNS for xrootd. This has a hostname dependency so must be done in the init script
RUN echo "sed -i -c \"s/^\($(hostname -i)\)\s\+.*$/\1 $(hostname -s).$(grep search /etc/resolv.conf | cut -d\  -f2) $(hostname -s)/\" /etc/hosts" >> ~/init_script.sh
# Change permissions of /etc/hosts back to default in init script
RUN echo "chmod 644 /etc/hosts" >> ~/init_script.sh

# Yum should use IPv4 (not necessarily needed)
RUN echo "ip_resolve=IPv4" >> /etc/yum.conf

# OKD containers are not running using systemd
# We omit this env variable entirely as we can assume no systemd in later images
# ENV CI_CONTEXT "nosystemd"

# Add cta user and group
RUN /usr/bin/getent passwd cta || /usr/sbin/useradd -s /bin/nologin -c "CTA system account" -g tape cta

# Use buildtree logic, because we're always in buildtree
# But do not re-define yum, not sure why that was ever done

# Give cta user access to storage devices
# None of these exist exist (Maybe because I'm doing something wrong?)
# RUN chmod 666 /dev/nst* /dev/st* /dev/sg*

# creating /var/log/cta needed by taped
RUN mkdir -p /var/log/cta \
    && chmod a+rwx /var/log/cta

CMD /etc/init_script.sh && sleep infinity
