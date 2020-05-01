flatten ()
{
    test -d __flattened_files || mkdir __flattened_files;
    find "$1" -type f -exec gcp -r --backup=numbered $(echo '{}') __flattened_files \;
}
