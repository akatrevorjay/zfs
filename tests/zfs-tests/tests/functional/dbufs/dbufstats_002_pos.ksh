#!/bin/ksh -p
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (c) 2016, Lawrence Livermore National Security, LLC.
#

. $STF_SUITE/tests/functional/dbufs/dbufs.kshlib
. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/include/math.shlib

#
# DESCRIPTION:
#
# STRATEGY:
#

DBUFS_FILE="/var/tmp/dbufs.out.$$"

function cleanup
{
	log_must rm -f $TESTDIR/file $DBUFS_FILE
}

verify_runnable "both"

log_assert "dbufs move from mru to mfu list"

log_onexit cleanup

log_must dd if=/dev/urandom bs=1M count=20 of="$TESTDIR/file"
log_must zpool sync

objid=$(stat --format="%i" "$TESTDIR/file")
log_note "Object ID for $TESTDIR/file is $objid"

log_must eval "cat /proc/spl/kstat/zfs/dbufs > $DBUFS_FILE"
log_must dbufstat.py -i "$DBUFS_FILE" -b -f pool,object,list
dbuf=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid" | wc -l)
mru=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid,list=1" | wc -l)
mfu=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid,list=3" | wc -l)
log_note "dbuf count is $dbuf, mru count is $mru, mfu count is $mfu"
verify_ne "0" "$mru" "mru count"
verify_eq "0" "$mfu" "mfu count"

log_must eval "cat $TESTDIR/file > /dev/null"
log_must eval "cat /proc/spl/kstat/zfs/dbufs > $DBUFS_FILE"
log_must dbufstat.py -i "$DBUFS_FILE" -b -f pool,object,list
dbuf=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid" | wc -l)
mru=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid,list=1" | wc -l)
mfu=$(dbufstat.py -bxn -i "$DBUFS_FILE" -F "object=$objid,list=3" | wc -l)
log_note "dbuf count is $dbuf, mru count is $mru, mfu count is $mfu"
verify_ne "0" "$mfu" "mfu count"

log_pass "dbufs move from mru to mfu list passed"
