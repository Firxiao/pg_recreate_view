#!/bin/bash
#usage: recrate views for postgresql;
#author firxiao
#date 2015.07.02


###config
HOST="ip or hostname"
DB_NAME="db name"
DB_USER="db user"
DB_PASSWORD="db password"
###



export LANG='C'
export PGPASSWORD="$DB_PASSWORD"

usage() {
	printf  "Useage: %s: -b <view_name> #backup view and dependent objects  \n" $(basename $0) >&2
	printf  "Useage: %s: -d <view_name> #delete view and dependent objects   \n" $(basename $0) >&2
	printf  "Useage: %s: -c  \"<sql>\"    #exec custom sql command   \n" $(basename $0) >&2
	printf  "Useage: %s: -r <view_name> #restore view and dependent objects  \n" $(basename $0) >&2
	exit 2
}


backup_view()
{
pg_dump -h $HOST -U $DB_USER -c -x -O -t $view  $DB_NAME > ${view}_bak.sql &&
echo "backup ${view} to ${view}_bak.sql"
}


check_deps()
{
psql -h $HOST -U $DB_USER  $DB_NAME -c "drop view $view;" 2> /tmp/dep_err.log
cat /tmp/dep_err.log |sed '1d;$d'|sed 's/DETAIL:  //g'|awk '{print $2}' >/tmp/deps.list
}


backup_deps()
{
while read dep
do
pg_dump -h $HOST -U $DB_USER -c -x -O -t $dep  $DB_NAME >> ${view}_bak.sql  &&
echo "backup $dep to ${view}_bak.sql"
done </tmp/deps.list
}



drop_view()
{
psql -h $HOST -U $DB_USER $DB_NAME -c "drop view $view CASCADE;"
}


restore_view()
{
psql -h $HOST -U $DB_USER $DB_NAME < ${view}_bak.sql
}

exec_sql()
{
psql -h $HOST -U $DB_USER $DB_NAME -c "$sql"
}

if [ $# = 0 ]
then
usage
fi



bflag=
dflag=
rflag=
cflag=

while getopts "b:d:r:c:t" arg
do
        case $arg in
                b)
			 bflag=1
		  	 view="$OPTARG"	
			 ;;
                d)
			dflag=1
			view="$OPTARG"
                        ;;
                r)
			rflag=1
			view="$OPTARG"
                        ;;
                c)
			cflag=1
			sql="$OPTARG"
                        ;;
                ?)
			usage
			;;
esac
done


if [ "$bflag" == "1" ]
then
	backup_view && check_deps && backup_deps
elif [ "$dflag" == "1" ]
then
	drop_view
elif [ "$rflag" == "1" ]
then
	restore_view
elif [ "$cflag" == "1" ]
then
	exec_sql
fi
exit 0
