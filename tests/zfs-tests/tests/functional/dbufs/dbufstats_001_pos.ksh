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

DBUFSTATS_FILE="/var/tmp/dbufstats.out.$$"
DBUFS_FILE="/var/tmp/dbufs.out.$$"

function cleanup
{
	log_must rm -f $TESTDIR/file $DBUFS_FILE $DBUFSTATS_FILE
}

function testdbufstat # stat_name dbufstat_filter
{
        name=$1
        filter=""

        [[ -n "$2" ]] && filter="-F $2"

        verify_eq \
	    $(cat "$DBUFSTATS_FILE" | grep -w "$name" | awk '{ print $3 }') \
	    $(dbufstat.py -bxn -i "$DBUFS_FILE" "$filter" | wc -l) \
	    "$name"
}

verify_runnable "both"

log_assert "dbufstats produces correct statistics"

log_onexit cleanup

log_must dd if=/dev/urandom bs=1M count=20 of="$TESTDIR/file"
log_must zpool sync

sleep 5

log_must eval "cat /proc/spl/kstat/zfs/dbufs > $DBUFS_FILE"
log_must eval "cat /proc/spl/kstat/zfs/dbuf_stats > $DBUFSTATS_FILE"

testdbufstat "dbuf_cache_count" "dbc=1"
testdbufstat "dbuf_cache_level_0" "dbc=1,level=0"
testdbufstat "dbuf_cache_level_1" "dbc=1,level=1"
testdbufstat "dbuf_cache_level_2" "dbc=1,level=2"
testdbufstat "dbuf_cache_level_3" "dbc=1,level=3"
testdbufstat "dbuf_cache_level_4" "dbc=1,level=4"
testdbufstat "dbuf_cache_level_5" "dbc=1,level=5"
testdbufstat "dbuf_cache_level_6" "dbc=1,level=6"
testdbufstat "dbuf_cache_level_7" "dbc=1,level=7"
testdbufstat "dbuf_cache_level_8" "dbc=1,level=8"
testdbufstat "dbuf_cache_level_9" "dbc=1,level=9"
testdbufstat "dbuf_cache_level_10" "dbc=1,level=10"
testdbufstat "dbuf_cache_level_11" "dbc=1,level=11"
testdbufstat "hash_dbuf_level_0" "level=0"
testdbufstat "hash_dbuf_level_1" "level=1"
testdbufstat "hash_dbuf_level_2" "level=2"
testdbufstat "hash_dbuf_level_3" "level=3"
testdbufstat "hash_dbuf_level_4" "level=4"
testdbufstat "hash_dbuf_level_5" "level=5"
testdbufstat "hash_dbuf_level_6" "level=6"
testdbufstat "hash_dbuf_level_7" "level=7"
testdbufstat "hash_dbuf_level_8" "level=8"
testdbufstat "hash_dbuf_level_9" "level=9"
testdbufstat "hash_dbuf_level_10" "level=10"
testdbufstat "hash_dbuf_level_11" "level=11"
testdbufstat "hash_elements" ""

log_pass "dbufstats produces correct statistics passed"
