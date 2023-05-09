#!/usr/bin/env python3

import os
import subprocess
import datetime

# Define a dictionary of cron expressions to bash commands
cron_to_bash = {
    '30 10 * * *': "echo 'This command runs every day at 10:30 AM' >> ~/cron.txt",
    '0 18 * * *': "echo 'This command runs every day at 6:00 PM' >> ~/cron.txt",
    '30 15 * * *': "echo 'This command runs every day at 6:00 PM' >> ~/cron.txt",
    '* * * * *': "echo 'This command runs every minute' >> ~/cron.txt",
}

def execute_bash_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    if error:
        print(f"Error: {error}")
    else:
        print(f"Output: {output}")

def parse_cron_expression(expression):
    fields = expression.split()
    return {
        "minute": fields[0],
        "hour": fields[1],
        "day_of_month": fields[2],
        "month": fields[3],
        "day_of_week": fields[4],
    }

def cron_expression_matches_time(parsed_cron, dt):
    minute_match = parsed_cron["minute"] == "*" or int(parsed_cron["minute"]) == dt.minute
    hour_match = parsed_cron["hour"] == "*" or int(parsed_cron["hour"]) == dt.hour
    day_of_month_match = parsed_cron["day_of_month"] == "*" or int(parsed_cron["day_of_month"]) == dt.day
    month_match = parsed_cron["month"] == "*" or int(parsed_cron["month"]) == dt.month
    day_of_week_match = parsed_cron["day_of_week"] == "*" or int(parsed_cron["day_of_week"]) == dt.weekday()

    return minute_match and hour_match and day_of_month_match and month_match and day_of_week_match

# Check if any cron expression matches the current time and execute the corresponding command
now = datetime.datetime.now()
for cron_expression, bash_command in cron_to_bash.items():
    parsed_cron = parse_cron_expression(cron_expression)
    if cron_expression_matches_time(parsed_cron, now):
        execute_bash_command(bash_command)

