#!/bin/bash

if [ $# -ne 1 ]; then
        echo "Enter directory";
    	exit 0;
fi

cd $1
>acl
echo "#!/bin/bash">recovery_acl.sh
echo "cd $1">>recovery_acl.sh
f='./'
# create acl file sorted by dir_level
for i in `seq 0 15`;do
  find . -mindepth $i -maxdepth $i -type d -exec getfacl {} +|grep -E '*UTS|file:'>>acl
done
sed -i 's/default\:user/\-dm\ u/g' acl
sed -i 's/default\:group/\-dm\ g/g' acl
sed -i 's/user\:/\-m\ u\:/g' acl
sed -i 's/group\:/\-m\ g\:/g' acl
sed -i 's/\#\ file\:\ /\.\//g' acl
sed -i 's,\\,\\\\,g' acl
sed -i "/^#/d" acl
 
while IFS='' read -r line ; do
  # grep dir name
  if echo "$line" | grep -q "$f" ; then
    dir="$line"
    continue
  fi
  echo setfacl $line '"'$dir'"'>>recovery_acl.sh
  # grep non def acl (for files)
  if echo "$line" | grep -q '\-m' ; then
    echo setfacl $line '"'$dir'"'/*>>recovery_acl.sh
  fi
done < "acl"
rm -f acl
sed -i "s/\\\134/\\\\\\\134/g" recovery_acl.sh
sed -i "s/\\\040/\\\\ /g" recovery_acl.sh