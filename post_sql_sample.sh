#!/bin/bash
#set -x
orc_sid=$1
sqlplus_user=`ps -ef|grep pmon_|grep -v grep |grep $orc_sid | awk '{print $1}'`
pid=`ps -ef|grep pmon_|grep -v grep |grep $orc_sid | awk '{print $2}'`
orc_home=`sudo ls -l /proc/$pid/exe | awk -F'>' '{ print $2 }' | sed 's/\/bin\/oracle$//' | sort | uniq|sed 's/^ *//g'`
export ORACLE_SID=$orc_sid
export ORACLE_HOME=$orc_home
export TNS_ADMIN=$ORACLE_HOME/network/admin
sql_output=`sudo su - $sqlplus_user <<EOF1
export ORACLE_SID=$orc_sid
export ORACLE_HOME=$orc_home
export TNS_ADMIN=$ORACLE_HOME/network/admin
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba"
set echo on
drop user hhpv cascade;
create user hhpv identified by hhpv;
grant resource,create session to hhpv;
ALTER USER hhpv quota unlimited on users;
conn hhpv/hhpv
create table hhpv_test (message varchar(200));
insert into hhpv_test values ('this is sample for post task');
EOF1`
sudo rm -f /tmp/dboutput.log
echo $sql_output > /tmp/dboutput.log