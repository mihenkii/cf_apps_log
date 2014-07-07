cf_apps_log
===========

a very simple way to collect app's log running on cloudfoundry 

Usage: 
1, make sure ssh and expect was installed on the cloudfoundry dea OS 
2, a log system used by your application, which print apps log to /var/vcap/home/. 
  /var/vcap/home/ is the path in warden, not your host os. 
3, add the scprit to crontab

root@146:/var/vcap# crontab -l

*/2 * * * * /bin/bash /var/vcap/rmkdir.sh > /var/vcap/log.txt 2>&1

In this demo, I push apps logs to a remote nginx root dir, 
so developers can get these log by a explorer easily.

you should push logs to anywhere you want. hdfs or a nfs server is a good choice. 
In the shell scprit, there some "hard code", 
be careful, please replace the "hard code" ip address username and password etc.
