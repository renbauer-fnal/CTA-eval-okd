#!/bin/bash

# @project        The CERN Tape Archive (CTA)
# @copyright      Copyright(C) 2021 CERN
# @license        This program is free software: you can redistribute it and/or modify
#                 it under the terms of the GNU General Public License as published by
#                 the Free Software Foundation, either version 3 of the License, or
#                 (at your option) any later version.
#
#                 This program is distributed in the hope that it will be useful,
#                 but WITHOUT ANY WARRANTY; without even the implied warranty of
#                 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                 GNU General Public License for more details.
#
#                 You should have received a copy of the GNU General Public License
#                 along with this program.  If not, see <http://www.gnu.org/licenses/>.

for COREFILE in $(ls /var/log/tmp/*cta-tpd-*.core); do

test -z ${COREFILE} && (echo "NO COREFILE FOUND, EXITING"; exit 1)

echo "PROCESSING COREFILE: ${COREFILE}"

yum install -y xrootd-debuginfo cta-debuginfo

cat <<EOF > /tmp/ctabt.gdb
file /usr/bin/cta-taped
core ${COREFILE}
thread apply all bt
quit
EOF

gdb -x /tmp/ctabt.gdb > ${COREFILE}.bt

echo "BACKTRACE AVAILABLE IN ${COREFILE}.bt"

done

exit 0
