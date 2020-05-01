median () 
{ 
    echo -e "$1" | tr ',' '\n' | sort -n | awk '{arr[NR]=$1}
   END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'
}
