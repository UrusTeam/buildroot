if [ "$USER" = "urusapp" ] ; then
    printf "Starting urusx\n"
    /usr/bin/urusx
else
    printf "Hi $USER!\n"
fi
