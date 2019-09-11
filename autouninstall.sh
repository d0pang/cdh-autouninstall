#!/bin/bash
#---------------------------------------------------
#updated 2019-05-26
#---------------------------------------------------
CURRENTPWD=`pwd`
#all agent note,but not manager node
nodelist=$CURRENTPWD/node.list
#all components
componentlist=$CURRENTPWD/components.list
#all users
userlist=$CURRENTPWD/user.list
#need to delete dirs
deletelist=$CURRENTPWD/delete.list
username=root
#currrent hostname
currentHost=`hostname`

#一、stop agnet service
scmAgentCmd="echo '[step 1] Stop cloudera-scm-agent service.....................';"
function stopClouderaScmAgernt() {
  sudo systemctl stop cloudera-scm-agent
  scmAgentCmd=${scmAgentCmd}"sudo systemctl stop cloudera-scm-agent;"
}


#二、remove components
componentsCmd="echo '[step 2] uninstall all components .........................';"
function executeRemoveComponents() {
  for component in `cat $componentlist`; do
    #local run
    sudo yum -y remove $component
    componentsCmd=${componentsCmd}"sudo yum -y remove $component;"
  done
}

#三、clean yum
cleanYumCmd="echo '[step 3] clean yum...........................................';"
function cleanYum() {
  sudo rm -f /etc/yum.repos.d/cloudera-manager.repo
  sudo yum clean all
  cleanYumCmd=${cleanYumCmd}"sudo rm -f /etc/yum.repos.d/cloudera-manager.repo;sudo yum clean all;"
}

#四、kill all user process
killProcessCmd="echo '[step 4] kill all user process............................';"
function killUserProcess() {
  while read u
  do
    i=`cat /etc/passwd |cut -f1 -d':'|grep -w "$u" -c`;
    if [ $i -gt 0 ];then
      pids=$(ps -u $u -o pid=);
      if [ ! -n "$pids" ];then
         echo "$u has no process.";
      else
        sudo kill -9 $pids;
        killProcessCmd=${killProcessCmd}"sudo kill -9 \$(ps -u $u -o pid=);"
      fi
    fi
  done < "$userlist"
}

#五、rm cm_process
umountCmd="echo '[step 5] uninstall cm_process..................................';"
function umountCmProcesses() {
  sudo umount cm_processes;
  umountCmd=${umountCmd}"sudo umount cm_processes;"
}

#六、rm user and group
rmUserCmd="echo '[step 6] rm user and group..................................';"
function rmUserGorup() {
  while read u
  do
        sudo userdel $u;
	sudo rm -rf /home/$u
        rmUserCmd=${rmUserCmd}"sudo userdel $u;"
  done < "$userlist"

  while read g
  do
        sudo groupdel  $g;
        rmUserCmd=${rmUserCmd}"sudo groupdel $g;"
  done < "$userlist"
}



#七、delete config、dependency、log and other information
deleteCmd="echo '[step 6] delete config、dependency、log and other information....';"
function deleteCmInfo() {
  while read line
  do
	#content=`echo $line | awk '$0 !~ /#/ {printf($0)}'`
	#if [ -n "$content" ]; then
	  sudo rm -rf $line
	  deleteCmd=${deleteCmd}"sudo rm -rf $line;"
	#fi
  done < $deletelist
}

#(1)run in manager node
#echo "Stop Cloudera Scm Server................................."
#sudo systemctl stop cloudera-scm-server
#sudo systemctl stop mysqld

#echo "Uninstall Clouder Manager Server and mysql"
#sudo yum -y remove cloudera-scm-server
#sudo yum -y remove mysqld

echo "$currentHost uninstall start..................................................."
#stopClouderaScmAgernt
#executeRemoveComponents
#cleanYum
#killUserProcess
#umountCmProcesses
rmUserGorup
deleteCmInfo
echo "$currentHost uninstall end....................................................."

#(2)run in agent node
for node in `cat $nodelist`; do
	echo "$node uninstall start..................................................."
	#cmds=`awk '$0 !~ /#/ {printf("%s", $0c);c=";"}END{print""}' cmd.list`
	#cmds=`awk '$0 !~ /#/ {printf("%s", $0c)}END{print""}' cmd.list`
	cmds=${scmAgentCmd}${componentsCmd}${cleanYumCmd}${killProcessCmd}${umountCmd}${rmUserCmd}${deleteCmd}
	ssh -t $username@$node "$cmds"
	echo "$node uninstall end....................................................."
done
echo "uninstall all done"
