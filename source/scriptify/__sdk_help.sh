__sdk_help () 
{ 
    __sdkman_echo_no_colour "";
    __sdkman_echo_no_colour "Usage: sdk <command> [candidate] [version]";
    __sdkman_echo_no_colour "       sdk offline <enable|disable>";
    __sdkman_echo_no_colour "";
    __sdkman_echo_no_colour "   commands:";
    __sdkman_echo_no_colour "       install   or i    <candidate> [version]";
    __sdkman_echo_no_colour "       uninstall or rm   <candidate> <version>";
    __sdkman_echo_no_colour "       list      or ls   [candidate]";
    __sdkman_echo_no_colour "       use       or u    <candidate> [version]";
    __sdkman_echo_no_colour "       default   or d    <candidate> [version]";
    __sdkman_echo_no_colour "       current   or c    [candidate]";
    __sdkman_echo_no_colour "       upgrade   or ug   [candidate]";
    __sdkman_echo_no_colour "       version   or v";
    __sdkman_echo_no_colour "       broadcast or b";
    __sdkman_echo_no_colour "       help      or h";
    __sdkman_echo_no_colour "       offline           [enable|disable]";
    __sdkman_echo_no_colour "       selfupdate        [force]";
    __sdkman_echo_no_colour "       flush             <candidates|broadcast|archives|temp>";
    __sdkman_echo_no_colour "";
    __sdkman_echo_no_colour "   candidate  :  the SDK to install: groovy, scala, grails, gradle, kotlin, etc.";
    __sdkman_echo_no_colour "                 use list command for comprehensive list of candidates";
    __sdkman_echo_no_colour "                 eg: \$ sdk list";
    __sdkman_echo_no_colour "";
    __sdkman_echo_no_colour "   version    :  where optional, defaults to latest stable if not provided";
    __sdkman_echo_no_colour "                 eg: \$ sdk install groovy";
    __sdkman_echo_no_colour ""
}
if [[ $0 != "-bash" ]]; then __sdk_help "$@"; fi
