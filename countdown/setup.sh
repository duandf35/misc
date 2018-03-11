#!/usr/bin/env bash

shelldir=$( cd $(dirname $0) && pwd )

cmd=$shelldir/ctd

echo $'#!/usr/bin/env bash\n' > $cmd
echo "$shelldir/ctd.py \$@" >> $cmd

chmod +x $shelldir/ctd.py

mv $cmd /usr/local/bin/ctd

chmod +x /usr/local/bin/ctd
