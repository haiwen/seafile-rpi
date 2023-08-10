#!/bin/bash

SEAFILE_ADMIN=test\@test.com
SEAFILE_ADMIN_PW=test
PACKAGE=$(find /PACKAGE_DIR -type f -iname "*.tar.gz")
echo -e "Using server package: $PACKAGE\n"

apt-get update && apt-get install python3 sqlite3 net-tools procps wget -y
if [[ "$PACKAGE" =~ buster ]]; then
    apt-get install libjpeg62-turbo -y
fi
if [[ "$PACKAGE" =~ bullseye ]]; then
    apt-get install libjpeg62-turbo -y
fi
if [[ "$PACKAGE" =~ bookworm ]]; then
    apt-get install libjpeg62-turbo -y
fi
if [[ "$PACKAGE" =~ focal ]]; then
    apt-get install libjpeg8 -y
fi
if [[ "$PACKAGE" =~ jammy ]]; then
    apt-get install libjpeg8 -y
fi
cd /opt
tar -xzf $PACKAGE
cd /opt/$(ls -1 /opt)

./setup-seafile.sh auto -n test -i 0.0.0.0
#enable seafdav for testing
sed -i 's/enabled = false/enabled = true/' ../conf/seafdav.conf
./seafile.sh start
sleep 30

netstat -ltepn|grep :8082
if [ $? -ne 0 ]; then
    echo "ERROR seafile did not start"
    ps axfu
    exit 1
fi
netstat -ltepn|grep :8080
if [ $? -ne 0 ]; then
    echo "ERROR seafdav did not start"
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
if [[ "$PACKAGE" =~ focal ]]; then
    apt-get install libmariadb3 -y
fi
if [[ "$PACKAGE" =~ jammy ]]; then
    apt-get install libmariadb3 -y
fi
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

if [[ "$PACKAGE" =~ bookworm ]]; then
    python3 -m pip install pymysql --break-system-packages
else
    python3 -m pip install pymysql
fi
tar -xzf $PACKAGE
cd /opt/$(ls -1 /opt)

./setup-seafile-mysql.sh auto -n test -i 0.0.0.0 -u seafile -w test -r test
#enable seafdav for testing
sed -i 's/enabled = false/enabled = true/' ../conf/seafdav.conf
./seafile.sh start
sleep 30

netstat -ltepn|grep :8082
if [ $? -ne 0 ]; then
    echo "ERROR seafile did not start"
    ps axfu
    exit 1
fi
netstat -ltepn|grep :8080
if [ $? -ne 0 ]; then
    echo "ERROR seafdav did not start"
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

echo "All tests ok"
exit 0
