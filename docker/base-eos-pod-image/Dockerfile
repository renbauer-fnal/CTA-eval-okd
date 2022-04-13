# Functional copy of buildtree-stage2-eos image with /opt/run/bin/init_pod.sh logic

FROM imageregistry.fnal.gov/cta-eval/cta-eval-okd-base-pod-image

RUN yum install -y \
      eos-client \
      eos-server \
  && \
    yum clean all \
  && \
    rm -rf /var/cache/yum

CMD sleep infinity
