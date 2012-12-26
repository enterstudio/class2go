#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server-5.5 --force-yes -qy

mysqladmin -u root password password 2>&1

cat <<EOF | mysql -u root --password=password
create database if not exists class2go;  
grant all on class2go.* to class2go@'10.33.33.34' identified by 'class2gopw';  

update mysql.user set Select_priv='Y',Insert_priv='Y',Update_priv='Y',Delete_priv='Y',Create_priv='Y',Drop_priv='Y',Reload_priv='Y',Shutdown_priv='Y',Process_priv='Y',File_priv='Y',Grant_priv='Y',References_priv='Y',Index_priv='Y',Alter_priv='Y',Show_db_priv='Y',Super_priv='Y',Create_tmp_table_priv='Y',Lock_tables_priv='Y',Execute_priv='Y',Repl_slave_priv='Y',Repl_client_priv='Y',Create_view_priv='Y',Show_view_priv='Y',Create_routine_priv='Y',Alter_routine_priv='Y',Create_user_priv='Y',Event_priv='Y',Trigger_priv='Y',Create_tablespace_priv='Y' where user='class2go';

flush privileges;
EOF

sed -i 's/^\(bind-address\)/\# \1/' /etc/mysql/my.cnf 
