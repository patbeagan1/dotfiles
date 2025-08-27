: << COMMENT
This can be set up with the following file 

"""
% cat ducktest.json                                                                         24-07-11 - 10:17:10
{ "test": 1, "test2": 4 }
{ "test": 3, "test2": 40 }
{ "test2": 40 }
"""

and used with 

"""
duck.sh ducktest.sh "where test2 > 20""
"""
COMMENT

function main () {
  local filename="$1"
  local query="$2"

  cat "$filename" | duckdb -c "select * from read_json('/dev/stdin')""$query"
}

main "$@"


