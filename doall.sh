#!/bin/bash
hosts="DOSERCN60001 DOSERCN60002 DOSERCN60003 DOSERCN60004 DOSERCN60005 DOSERCN60006 DOSERCN60007"
for node in $hosts; do
	echo "$node start:###################################################################`date`"
	#cmds="hostnamectl set-hostname ${node}.LTS.LOCAL"
	#ssh -t $node "$cmds"
	echo "$node   end:###################################################################`date`"
done
