#!/usr/bin/env -S deno run --allow-run

/*
* Hardcoded list of commands to test
*
* While a little wasteful, each of these commands is run without sending the output to stdout
* then we will give the user the option to run the successful commands again
* so that they can see the output.
*
* These will show the commands which are installed with each of these package managers.
* */
const commands = [
    ["brew", "list"],
    ["apt", "list", "--installed"],
    ["yum", "list", "installed"],
    ["dnf", "list", "--installed"],
    ["zypper", "se", "--installed-only"],
    ["pacman", "-Q"],
    ["port", "installed"],
    ["rpm", "-q"],
    ["snap", "list"],
    ["flatpak", "list"],
    ["npm", "list", "-g"],
    ["cargo", "install", "--list"],
    ["pip", "show"],
    ["pip3", "show"],
    ["gem", "list", "--installed"],
    ["pear", "list"],
    ["composer", "show"],
    ["dotnet", "nuget", "locals", "all", "--list"],
    ["go", "list", "-m"],
    ["conda", "list"],
];

async function runCommands(commands: string[][]) {
    const successfulCommands: string[][] = [];

    for (const command of commands) {
        try {
            // Run the command
            const process = Deno.run({
                cmd: command,
                stdout: "null", // Ignore the stdout
                stderr: "null", // Ignore the stderr
            });

            // Wait for the command to finish and get the status
            const {code} = await process.status();

            // Check if the command was successful
            if (code === 0) {
                successfulCommands.push(command);
            }

            process.close();
        } catch (error) {
            // ignoring errors, because we're just checking if the programs exist on the current machine.
        }
    }

    return successfulCommands;
}

// Run the commands and print the ones that succeed
runCommands(commands)
    .then(successfulCommands => {
        successfulCommands
            .map((it) => it.join(" "))
            .forEach((it) => console.log(it))
    });
