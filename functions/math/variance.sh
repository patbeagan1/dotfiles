variance () 
{ 
    math $(sum $(echo $(for i in $(echo "$1" | tr ',' ' '); do math $(math $i-$(mean "$1"))^2; done) | tr ' ' ',')) / $(count_list "$1")
}
