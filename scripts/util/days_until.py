#!/usr/bin/env python3 

import sys
import argparse
from datetime import datetime
import math

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

    if time_until.days == -1:
        return f"Today is {event_name}"
    
    # Offset to midnight
    curr_day = datetime.now()
    offset = datetime.now() - datetime(year=curr_day.year, month=curr_day.month, day=curr_day.day)

    if str(time_until) != str(abs(time_until)):
        raise ValueError("Time can't be negative")

    # Extract years, months, weeks, and days
    v = datetime.min + time_until + offset
    years = v.year - 1 
    months = v.month - 1
    weeks = (v.day - 1) / 7
    days = (v.day - 1) % 7 

    years = int(years)
    months = int(months)
    weeks = int(weeks)
    days = int(days)

    print(time_until)
    print("xyp")
    print(f"{years} {months} {weeks} {days}")

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

