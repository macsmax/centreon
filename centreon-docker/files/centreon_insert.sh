#!/bin/bash
HOST=18
echo "" > /tmp/insert_sql.sql
for i in `cat /tmp/machines`
do
   NAME=`echo $i | cut -f1 -d:`
   IP=`echo $i | cut -f2 -d:`
   echo "insert into host values ('$HOST',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$NAME','$NAME','$IP',NULL,NULL,NULL,NULL,'2','2','2',NULL,'2','2',NULL,'2',NULL,NULL,'2',NULL,'2','2','2',NULL,NULL,'2','0','0',NULL,NULL,NULL,NULL,NULL,NULL,'1','1');" >> /tmp/insert_sql.sql
   echo "insert into host_template_relation values ('$HOST', '2', '1');" >> /tmp/insert_sql.sql
   echo "insert into extended_host_information values('','$HOST',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);" >> /tmp/insert_sql.sql
#   echo "insert into host_service_relation values ('', NULL,$HOST,NULL,3);" >> /tmp/insert_sql.sql
#   echo "insert into host_service_relation values ('', NULL,$HOST,NULL,28);" >> /tmp/insert_sql.sql
   let HOST++
done
