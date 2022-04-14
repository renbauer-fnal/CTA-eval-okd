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

# Add this for SSI prococol buffer workflow (xrootd >=4.8.2)
echo "mgmofs.protowfendpoint ctafrontend:10955" >> /etc/xrd.cf.mgm
echo "mgmofs.protowfresource /ctafrontend"  >> /etc/xrd.cf.mgm

# Add configmap based configuration (initially Namespace)
test -f /etc/config/eos/xrd.cf.mgm && cat /etc/config/eos/xrd.cf.mgm >> /etc/xrd.cf.mgm

mv -v /var/eos/config/host /var/eos/config/${eoshost}
