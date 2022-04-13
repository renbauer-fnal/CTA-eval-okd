This is a recreation of the EOSCTA continuous integration deployment, but with some logic moved around so it can run in OKD.

OKD implies some restrictions on container permissions which make a lot of the existing continuous integration configuration unusable as it relies on lengthy init scripts which require root permissions.

In order to avoid this incompatibility, we'll be attempting to move as much of the logic as possible into the image build process, and modifying permissions where necessary to allow init operations to be performed without root.

So far, we have the following:

image name | EOSCTA CI analog

base-cta-image | buildtree-stage1-rpms

base-eos-image | buildtree-stage2-eos

(none) | buildtree-stage3-scripts (these scripts are no longer needed, as logic has largely been moved into image build)

base-pod-image | buildtree-stage1-rpms + /opt/bin/init_pod.sh

base-eos-pod-image | buildtree-stage2-eos + /opt/bin/init_pod.sh

client-image | buildtree-stage1-rpms + opt/bin/client.sh

---

