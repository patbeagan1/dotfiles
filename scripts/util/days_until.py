#!/usr/bin/env python3 

import sys
import argparse
from datetime import datetime

def calculate_time_until(event_date_str, event_name):
    try:
        # Parsing the event date
        event_date = datetime.strptime(event_date_str, "%Y-%m-%d")
    except ValueError:
        raise ValueError("Date must be in YYYY-MM-DD format")

    # Current date and time
    current_date = datetime.now()
    
    # Time until the event
    time_until = event_date - current_date

    if str(time_until) != str(abs(time_until)):
        raise ValueError("Time can't be negative")

    # Extract years, months, weeks, and days
    years, remainder = divmod(time_until.days, 365)
    months, remainder = divmod(remainder, 30)
    weeks, days = divmod(remainder, 7)

    # Creating parts of the output string
    parts = []
    if years > 0:
        parts.append(f"{years} years")
    if months > 0:
        parts.append(f"{months} months")
    if weeks > 0 and months == 0:
        parts.append(f"{weeks} weeks")
    if days > 0 and months == 0:
        parts.append(f"{days} days")

    # Joining the parts with commas and adding the event name
    output = ", ".join(parts)
    output += f" until {event_name}"

    return output

def main():
    parser = argparse.ArgumentParser(description="Calculate time until a specified event date.")
    parser.add_argument("event_date", help="The date of the event in YYYY-MM-DD format")
    parser.add_argument("event_name", help="The name of the event")

    args = parser.parse_args()

    try:
        result = calculate_time_until(args.event_date, args.event_name)
        print(result)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()

