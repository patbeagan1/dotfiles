#!/usr/bin/env node

function splitBashCommand(bashCommand) {
    const regex = /(?:[^\s"']+|"[^"]*"|'[^']*')+/g;
    const args = bashCommand.match(regex) || [];
    return args;
  }
  
  function joinArgsWithBackslashNewline(args) {
    const result = args.reduce((acc, arg, index) => {
      if (arg === '|') {
        return acc.trim() + ' \\\n  ' + arg;
      }
      if (index > 0 && args[index - 1] === '|') {
        return acc + ' ' + arg;
      }
      if (index > 0 && arg.startsWith('-')) {
        return acc + ' \\\n  ' + arg;
      }
      if (index > 0) {
        return acc + ' ' + arg;
      }
      return acc + arg;
    }, '');
  
    return result;
  }
  
  function formatBashCommand(bashCommand) {
    const argsArray = splitBashCommand(bashCommand);
    return joinArgsWithBackslashNewline(argsArray);
  }
  
  // Check if there is an argument provided
  if (process.argv.length < 3) {
    console.error('Error: Please provide a bash command as an argument.');
    process.exit(1);
  }
  
  const bashCommand = process.argv[2];
  const result = formatBashCommand(bashCommand);
  console.log(result);
  
