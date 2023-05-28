#!/bin/bash

SEAFILE_ADMIN=test\@test.com
SEAFILE_ADMIN_PW=test
PACKAGE=$(find /PACKAGE_DIR -type f -iname "*.tar.gz")
echo -e "Using server package: $PACKAGE\n"

apt-get update && apt-get install python3 sqlite3 net-tools procps wget -y
cd /opt
tar -xzf $PACKAGE
cd /opt/$(ls -1 /opt)

./setup-seafile.sh auto -n test -i 0.0.0.0
./seafile.sh start
sleep 10
netstat -ltepn|grep :8082
if [ $? -ne 0 ]; then
    echo "ERROR seafile did not start"
    ps axfu
    exit 1
fi

sed -i 's/= ask_admin_email()/= \"${SEAFILE_ADMIN}\"/' check_init_admin.py
sed -i 's/= ask_admin_password()/= \"${SEAFILE_ADMIN_PW}\"/' check_init_admin.py
./seahub.sh start
sleep 10

netstat -ltepn|grep :8000
if [ $? -ne 0 ]; then
    echo "ERROR seahub did not start"
    ps axfu
    exit 1
fi
wget http://127.0.0.1:8000 -q -O - | grep login > /dev/null
if [ $? -ne 0 ]; then
    echo "ERROR seahub did not respond"
    exit 1
fi

./seahub.sh stop
./seafile.sh stop
sleep 1
cd /opt
rm -rf /opt/*


apt-get install mariadb-server python3-pip -y
service mariadb start
service mysql start
sleep 1
netstat -ltepn|grep :3306
if [ $? -ne 0 ]; then
    echo "ERROR mariadb did not start"
    ps axfu
    exit 1
fi
mysqladmin -u root password test

python3 -m pip install pymysql
tar -xzf $PACKAGE
cd /opt/$(ls -1 /opt)

./setup-seafile-mysql.sh auto -n test -i 0.0.0.0 -u seafile -w test -r test
./seafile.sh start
sleep 10
netstat -ltepn|grep :8082
if [ $? -ne 0 ]; then
    echo "ERROR seafile did not start"
    ps axfu
    exit 1
fi

eval "sed -i 's/= ask_admin_email()/= \"${SEAFILE_ADMIN}\"/' check_init_admin.py"
eval "sed -i 's/= ask_admin_password()/= \"${SEAFILE_ADMIN_PW}\"/' check_init_admin.py"
./seahub.sh start
sleep 10

netstat -ltepn|grep :8000
if [ $? -ne 0 ]; then
    echo "ERROR seahub did not start"
    ps axfu
    exit 1
fi
wget http://127.0.0.1:8000 -q -O - | grep login > /dev/null
if [ $? -ne 0 ]; then
    echo "ERROR seahub did not respond"
    exit 1
fi

echo "All tests ok"
exit 0
