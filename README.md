### pg_recreate_view

recreate view tool for postgresql

##make config correct
```
###config
HOST="ip or hostname"
DB_NAME="db name"
DB_USER="db user"
DB_PASSWORD="db password"
###

```
##run

```
#./recreate_views.sh
Useage: recreate_views.sh: -b <view_name> #backup view and dependent objects  
Useage: recreate_views.sh: -d <view_name> #delete view and dependent objects   
Useage: recreate_views.sh: -c  "<sql>"    #exec custom sql command   
Useage: recreate_views.sh: -r <view_name> #restore view and dependent objects 

```
