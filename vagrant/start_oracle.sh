
# oracle init works.
if getent passwd oracle > /dev/null; then

su - oracle << END
source ~/.bash_profile
# mount,open and start oracle instant.
echo "startup;" | sqlplus / as sysdba
lsnrctl start
END

fi

