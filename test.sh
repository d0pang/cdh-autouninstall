#!/bin/bash
u=chrony
i=`cat /etc/passwd |cut -f1 -d':'|grep -w "$u" -c`;
if [ $i -gt 0 ];then
  echo $i
  p=$(ps -u $u -o pid=)
  echo $p
  if [ ! -n "$p" ]; then
    echo "IS NULL"
  else
     sudo kill -9 $p;
  fi
fi

