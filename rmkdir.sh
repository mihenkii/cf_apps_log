#!/bin/bash -ex
cd /var/vcap

remote_ip=192.168.3.4
remote_user=root
remote_passwd=password
remote_dir=/tmp
now_date=`date +"%F"`
now_time=$(date +"%H_%M")

base_dir=/var/vcap
warden_dir=/var/vcap/data/warden/depot

function_dirs() {
    echo > /var/vcap/dirs.tmp
    for dirs in `ls $1 -l |grep -v total | grep -v tmp |awk '{print $9}'`
	do
    		echo "$dirs" 
	done
}
function_dirs $warden_dir > /var/vcap/dirs.tmp

function_cleanlog() {
	files=`ls $1`
	for file in files
	do
		if [ "$file"="env.log" ];then
			continue
		else 
			echo "" > $file
		fi
	done
}

function_mkdirremotedir() {
./rmkdir.exp $1 $2 $3 $4
}

function getappinfo() {
        IFS== 
	json=
	while read name dept 
	do 
	   if [ "$name" == "VCAP_APPLICATION" ]; then
		json=$dept 
		fi
	done < $1

	arr=(${json//'"'/})
	IFS=","
	arr=($arr)
	appname=
	instanceindex=
	for i in ${arr[@]}
	do
   		IFS=":"
   		arrtmp=($i)
   		if [ "${arrtmp[0]}" == 'application_name' ]; then
			appname=${arrtmp[1]}
   		fi
   		if [ "${arrtmp[0]}" == 'instance_index' ]; then
			instanceindex=${arrtmp[1]}
   		fi
	done
	echo "$appname:$instanceindex" > appinfo.tmp
}


function_rmkdir() {
	cd $base_dir
	while read line 
	do
		if [ "" = "$line" ];then 
			echo "there is no app in this dea." 
		else
			getappinfo $warden_dir/$line/tmp/rootfs/home/vcap/logs/env.log
			appname=$(cut -d : -f 1 appinfo.tmp)
			instanceindex=$(cut -d : -f 2 appinfo.tmp)
			function_mkdirremotedir $remote_ip $now_date $appname $instanceindex
			./rcpfile.exp $remote_ip $warden_dir/$line/tmp/rootfs/home/vcap/logs /tmp/logs/$now_date/$appname/$instanceindex
		fi
	done < dirs.tmp
}

cd $base_dir
function_rmkdir
# function_transfile
