#!/usr/bin/env python3
# flake8: noqa
#
# Copyright (c) 2017 Scot W. Stevenson <scot.stevenson@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
"""Test routines for arc_summary3.py"""

# Python expects the test routine and the program to be close together, if
# not even in the same directory. The ZFS directory structure, however,
# splits them far apart, so we have do do some trickery with the pathing.
# This in turn makes flake8 (and pylint) really unhappy, so we turn it off
# (see second line at the top).
import os
import sys
my_path = os.environ['PATH'].split(':')
sys.path.extend(my_path)
import arc_summary3
from unittest import TestCase, main


class HelpersTestCase(TestCase):
    """Tests helper functions"""

    def test_f_bytes(self):
        """Test human-readable string for size"""

        table = (('0', '0 Bytes'),
                 ('100', '100 Bytes'),
                 ('1023', '1023 Bytes'),
                 ('1024', '1.0 KiB'),
                 ('1025', '1.0 KiB'),
                 (str(2**10), '1.0 KiB'),
                 (str(2**10+1), '1.0 KiB'),
                 (str(2**20), '1.0 MiB'),
                 (str(2**20+1), '1.0 MiB'),
                 (str(2**30), '1.0 GiB'),
                 (str(2**30+1), '1.0 GiB'),
                 (str(2**40), '1.0 TiB'),
                 (str(2**40+1), '1.0 TiB'),
                 (str(2**50), '1.0 PiB'),
                 (str(2**50+1), '1.0 PiB'),
                 (str(2**60), '1.0 EiB'),
                 (str(2**60+1), '1.0 EiB'),
                 (str(2**70), '1.0 ZiB'),
                 (str(2**70+1), '1.0 ZiB'),
                 (str(2**80), '1.0 YiB'),
                 (str(2**80+1), '1.0 YiB'),
                 (0, '0 Bytes'))  # can handle numbers?

        for entry in table:

            given = entry[0]
            expected = entry[1]
            self.assertEqual(arc_summary3.f_bytes(given), expected)

    def test_f_hits(self):
        """Test human-readable string for number of hits"""

        table = (('0', '0'),
                 ('100', '100'),
                 ('1000', '1.0k'),
                 ('1001', '1.0k'),
                 (str(10**3), '1.0k'),
                 (str(10**3+1), '1.0k'),
                 (str(10**6), '1.0M'),
                 (str(10**6+1), '1.0M'),
                 (str(10**9), '1.0G'),
                 (str(10**9+1), '1.0G'),
                 (str(10**12), '1.0T'),
                 (str(10**12+1), '1.0T'),
                 (str(10**15), '1.0P'),
                 (str(10**15+1), '1.0P'),
                 (str(10**18), '1.0E'),
                 (str(10**18+1), '1.0E'),
                 (str(10**21), '1.0Z'),
                 (str(10**21+1), '1.0Z'),
                 (str(10**24), '1.0Y'),
                 (str(10**24+1), '1.0Y'),
                 (0, '0'))  # can handle numbers?

        for entry in table:
            given = entry[0]
            expected = entry[1]
            self.assertEqual(arc_summary3.f_hits(given), expected)

    def test_f_perc(self):
        """Test human-readable string for percentages."""

        table = (('0', '0', 'n/a'),  # catch division by zero
                 ('50', 100, '50.0 %'),  # mix numbers and strings
                 (1, 100, '1.0 %'),
                 (0.1, 100, '0.1 %'),
                 (1, 10000, '< 0.1 %'),  # special cases
                 ('5', '100', '5.0 %'))

        for entry in table:
            given1 = entry[0]
            given2 = entry[1]
            expected = entry[2]
            self.assertEqual(arc_summary3.f_perc(given1, given2), expected)


if __name__ == '__main__':
    main()
