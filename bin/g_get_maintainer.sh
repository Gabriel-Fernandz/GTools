
list=$1
path_patches=$2


echo dir=$1


to_list=`./scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nol $path_patches $1/* 2> /dev/null`
cc_list=`./scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nom $path_patches $1/* 2> /dev/null`

echo to_list=$to_list
echo cc_list=$cc_list