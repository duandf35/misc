#!/usr/bin/env bash

shelldir=$( cd $(dirname $0) && pwd )

cmd=$shelldir/nginx-proxy

echo $'#!/usr/bin/env bash\n' > $cmd
echo "$shelldir/start.sh \$@" >> $cmd

chmod +x $shelldir/start.sh

mv $cmd /usr/local/bin/nginx-proxy

chmod +x /usr/local/bin/nginx-proxy
