#!/bin/bash

#Launching R server.
Rscript run_Rserve.R 45678 &

HOST=`hostname`

echo Host=$HOST

DIR=/tmp
DIR_ALT=/tmp
find /tmp/ -user $USER -mtime +5 2> /dev/null |xargs rm -rf

random_seed=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
mongo_db_folder=$DIR/$random_seed

port=`python get_free_port.py`
echo Puerto:$port

index=1
echo $mongo_db_folder
mkdir $mongo_db_folder
echo `ls -la $mongo_db_folder`

/usr/bin/mongod --logpath $mongo_db_folder/log.log --dbpath $mongo_db_folder --port $port --smallfiles --noprealloc --nojournal &

sleep 60
cat $mongo_db_folder/log.log

if [ ! -f $mongo_db_folder/log.log ]
then
	mongo_db_folder=$DIR_ALT/$random_seed
        mkdir $mongo_db_folder
        /usr/bin/mongod --logpath $mongo_db_folder/log.log --dbpath $mongo_db_folder --port $port --smallfiles --noprealloc --nojournal &
        sleep 60
fi
cat $mongo_db_folder/log.log
export SPEARMINT_DB_ADDRESS="mongodb://localhost:$port/"
echo $SPEARMINT_DB_ADDRESS

python ~/doctorado/Spearmint/spearmint/main.py .
python compute_optimum.py .
/usr/bin/mongod --shutdown --logpath $mongo_db_folder/log.log --dbpath $mongo_db_folder/ --port $port --smallfiles --noprealloc --nojournal
rm -rf $mongo_db_folder
