# To differentiate, pipe to sed "s|STD|BIBI|g"
echo STDOUT > /dev/stdout
echo -e '\033[0;31m\033[38;1m\033[38;3mSTDERR' > /dev/stderr
