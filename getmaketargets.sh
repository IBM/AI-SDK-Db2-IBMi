#!/QOpenSys/usr/bin/sh
echo .build/src/conf.sql.done
echo .build/src/conf_rcac.sql.done
ls -b src/*/*.sql | awk '{print ".build/" $1".done";}'