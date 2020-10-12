#!/usr/bin/env node

var readInput = function(callback) {
    var input = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('readable', function() {
        var chunk = process.stdin.read();
        if (chunk !== null) {
            input += chunk;
        }
    });
    process.stdin.on('end', function() { callback(input); });
}
var initScript = function(input) { console.log(input) }
readInput(initScript);