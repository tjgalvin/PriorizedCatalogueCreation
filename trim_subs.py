#! python

"""
Input should be a joined table of priorized fitting.

Output will be a table with a reduced number of columns.
sub band columns that are redundant are removed.
"""

__author__ = 'PaulHancock'

from astropy import table
import os, sys

if not len(sys.argv)==3:
    print "usage trim_table.py input output"
    sys.exit(1)
infile = sys.argv[-2]
outfile = sys.argv[-1]


tab = table.Table.read(infile)

# assuming priorized=1 these columns are either redundant or full of -1
# so we cut them
params = ['err_a','err_b','ra','ra_str','dec','dec_str','err_ra','err_dec',
          'err_pa','flags', 'source', 'island']

killring = []
for a in tab.colnames:
    for p in params:
        if a.startswith(p):
            killring.append(a)
            break

tab.remove_columns(killring)

# There are multiple columns containing the uuid, and they have the same uuid across each column
uuidcols = [a for a in tab.colnames if a.startswith('uuid')]

# find the first not empty uuid and keep that value
uuids = []
for row in tab[uuidcols]:
    uuids.append(''.join(row[:36]))

# replace the multiple uuid columns with one column
tab.remove_columns(uuidcols)
tab['uuid'] = uuids

if os.path.exists(outfile):
    os.remove(outfile)
tab.write(outfile)
