#!/bin/bash


pdf2scaledpng "$@"
#!/bin/bash

pdf2scaledpng () 
{ 
    local filename="$1";
    local outputbase="$1".png;
    pdf2png "$filename";
    pngresize "$outputbase" 25 mdpi;
    pngresize "$outputbase" 37 hdpi;
    pngresize "$outputbase" 50 xhdpi;
    pngresize "$outputbase" 75 xxhdpi;
    pngresize "$outputbase" 100 xxxhdpi
}

pdf2scaledpng "$@"
