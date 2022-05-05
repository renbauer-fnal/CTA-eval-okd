# Must be done post startup due to hostname reliance

eoshost=`hostname -f`

EOS_INSTANCE=`hostname -s`
TAPE_FS_ID=65535
CTA_BIN=/usr/bin/eoscta_stub
CTA_XrdSecPROTOCOL=sss
CTA_PROC_DIR=/eos/${EOS_INSTANCE}/proc/cta
CTA_WF_DIR=${CTA_PROC_DIR}/workflow
# dir for cta tests only for eosusers and powerusers
CTA_TEST_DIR=/eos/${EOS_INSTANCE}/cta
# dir for gRPC tests, should be the same as eos.prefix in client.sh
GRPC_TEST_DIR=/eos/grpctest
# dir for eos instance basic tests writable and readable by anyone
EOS_TMP_DIR=/eos/${EOS_INSTANCE}/tmp

# setup eos host and instance name
  sed -i -e "s/DUMMY_HOST_TO_REPLACE/${eoshost}/" /etc/sysconfig/eos
  sed -i -e "s/DUMMY_INSTANCE_TO_REPLACE/${EOS_INSTANCE}/" /etc/sysconfig/eos
  sed -i -e "s/DUMMY_HOST_TO_REPLACE/${eoshost}/" /etc/xrd.cf.mgm
  sed -i -e "s/DUMMY_INSTANCE_TO_REPLACE/${EOS_INSTANCE}/" /etc/xrd.cf.mgm
  sed -i -e "s/DUMMY_HOST_TO_REPLACE/${eoshost}/" /etc/xrd.cf.mq
  sed -i -e "s/DUMMY_HOST_TO_REPLACE/${eoshost}/" /etc/xrd.cf.fst

export EOS_MGM_ALIAS=${eoshost}

# Add this for SSI protocol buffer workflow (xrootd >=4.8.2)
echo "mgmofs.protowfendpoint ctafrontend:10955" >> /etc/xrd.cf.mgm
echo "mgmofs.protowfresource /ctafrontend"  >> /etc/xrd.cf.mgm

# Add configmap based configuration (initially Namespace)
# TODO: /etc/config/eos/xrd.cf.mgm comes from a configmap which is not yet implemented. For now we cheat** which may be okay if we don't need to configure this for our environment.
# test -f /etc/config/eos/xrd.cf.mgm && cat /etc/config/eos/xrd.cf.mgm >> /etc/xrd.cf.mgm
echo "\nmgmofs.nslib /usr/lib64/libEosNsInMemory.so" >> /etc/xrd.cf.mgm

mv -v /var/eos/config/host /var/eos/config/${eoshost}

# Skip starting quarkDB because we are using InMemory...
# cat /etc/config/eos/xrd.cf.mgm | grep mgmofs.nslib | grep -qi eosnsquarkdb && /opt/run/bin/start_quarkdb.sh

source /etc/sysconfig/eos

# Waiting for /CANSTART file before starting eos
# TODO: /CANSTART is added by create_instance.sh after configuring a lot of KDC stuff. We need to find a way to configure this asynchronously.

# Write eos keytab for SSS authentication, which is enforced by mgmofs
echo -n '0 u:daemon g:daemon n:ctaeos+ N:6361884315374059521 c:1481241620 e:0 f:0 k:1a08f769e9c8e0c4c5a7e673247c8561cd23a0e7d8eee75e4a543f2d2dd3fd22' > /etc/eos.keytab
chmod 400 /etc/eos.keytab

# start and setup eos for xrdcp to the ${CTA_TEST_DIR}, no systemd
# XRDPROG is set by image build
# These are usually run as daemon user, but that may not be possible from
# container user. We may have to rethink the user structure to make this ok.
$XRDPROG -n fst -c /etc/xrd.cf.fst -l /var/log/eos/xrdlog.fst -b # -Rdaemon
$XRDPROG -n mq -c /etc/xrd.cf.mq -l /var/log/eos/xrdlog.mq -b # -Rdaemon
$XRDPROG -n mgm -c /etc/xrd.cf.mgm -m -l /var/log/eos/xrdlog.mgm -b # -Rdaemon

# TODO: skip enabling security options because this isn't configured yet
# eos vid enable krb5
# eos vid enable sss
# eos vid enable unix
