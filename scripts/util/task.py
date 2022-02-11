#!/usr/bin/env python3

import argparse
import csv
import datetime
import logging
import sys
from argparse import Namespace
from dataclasses import dataclass
from pathlib import Path

import humanize
import pandas as pd
from dateutil.parser import parser

seconds_in_day = 86400


def main():
    local_parser = LocalParser()
    args = local_parser.parse()
    main = Main()

    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    if args.read or args.next:
        csv = main.read_tasks(DataMapper(sprint_manager=SprintManager(
            sprint_length=args.sprint_length if args.sprint_length else 14,
            sprint_points=args.sprint_points if args.sprint_points else 60
        )))
        print_final_results(args, csv)
    elif args.init:
        main.init_tasks()
    else:
        main.append_tasks(Row(
            datetime.datetime.now(),
            local_parser.get_due_timestamp(args.due),
            args.estimate if args.priority else 10,
            args.priority if args.priority else 10,
            " ".join(args.name)
        ))


def print_final_results(args, csv):
    csv["Con"] = csv["Confidence"]
    output = csv[["Due", "Con", "Name"]]
    if args.next:
        entry = output.iloc[0]
        print(f"Due  : {entry['Due']}")
        print(f"Name : {entry['Name']}")
    else:
        logging.info("\n" + csv.to_string())
        print(output)


@dataclass
class Row:
    submitted: datetime
    due: datetime
    estimate: str
    priority: str
    name: str


class LocalParser():
    def parse(self) -> Namespace:
        parser = argparse.ArgumentParser()
        parser.add_argument("--estimate", "-e", type=int)
        parser.add_argument("--due", "-d", choices=["day", "week", "sprint", "month", "year"])
        parser.add_argument("--priority", "-p", type=int)
        parser.add_argument("--read", "-r", action='store_true')
        parser.add_argument("--sprint-length", "-sl", type=int)
        parser.add_argument("--sprint-points", "-sp", type=int)
        parser.add_argument("--init", action='store_true')
        parser.add_argument("--next", action='store_true')
        parser.add_argument("--verbose", "-v", action='store_true')
        parser.add_argument("name", nargs='+' if self.is_name_required() else '*')
        args = parser.parse_args()
        return args

    @staticmethod
    def get_due_timestamp(it) -> datetime:
        current = datetime.datetime.now()
        if it == "day":
            return current + datetime.timedelta(days=1)
        if it == "week":
            return current + datetime.timedelta(weeks=1)
        if it == "sprint":
            return current + datetime.timedelta(weeks=2)
        if it == "month":
            return current + datetime.timedelta(weeks=4)
        if it == "year":
            return current + datetime.timedelta(weeks=52)
        else:
            return current + datetime.timedelta(weeks=4)

    @staticmethod
    def is_name_required():
        return not any([it in sys.argv for it in ['--read', '--init', '--next']])


@dataclass()
class SprintManager:
    sprint_points: int = 50
    sprint_length: int = 14  # days
    sprint: int = 1
    count: int = 0

    def reset(self):
        self.count = 0
        self.sprint = 0

    def apply_ticket(self, it):
        if (self.count + it) < self.sprint_points:
            self.count += it
            return self.sprint
        else:
            self.count = it
            self.sprint += 1
            return self.sprint

    def sprint_completion_date(self, sprint: int):
        return datetime.datetime.now() + datetime.timedelta(days=((sprint) * self.sprint_length))

    def ticket_completion_time(self, estimate: int):
        return datetime.timedelta(days=estimate * (self.sprint_length / self.sprint_points))

    def ticket_remaining_time(self, estimate: int):
        return \
            datetime.timedelta(days=self.sprint_length) - \
            self.ticket_completion_time(estimate) - \
            self.ticket_completion_time(self.count)


class DataMapper():

    def __init__(self, sprint_manager: SprintManager):
        self.parser = parser()
        self.sprint_manager = sprint_manager

    def map_submission(self, it):
        due = self.parser.parse(it["Due"])
        return (due - datetime.datetime.now()).total_seconds() / seconds_in_day

    def map_human_time_due(self, it):
        due = self.parser.parse(it["Due"])
        submission_due = datetime.datetime.now() - due
        return humanize.naturaltime(submission_due)

    def map_human_time_submitted(self, it):
        submission = self.parser.parse(str(it["Submitted"]))
        return humanize.naturaltime(datetime.datetime.now() - submission)

    def map_adjusted_priority(self, it):
        return it["Time Remaining"] * it["Priority"] * it["Estimate"]

    def map_sprints(self, it: int):
        return self.sprint_manager.apply_ticket(it)

    def map_sprint_confidence(self, it):
        sprint = it["Sprint"]
        due = self.parser.parse(str(it["Due"]))
        estimate = it["Estimate"]
        self.sprint_manager.apply_ticket(estimate)
        sprint_completion_date = self.sprint_manager.sprint_completion_date(sprint)
        ticket_remaining_time = self.sprint_manager.ticket_remaining_time(estimate)
        return ((due - (sprint_completion_date - ticket_remaining_time))).days

    def map_on_track(self):
        last = self.IntByReference()

        def accumulate(it):
            last.value += it
            return last.value

        return accumulate

    @dataclass
    class IntByReference:
        value: int = 0


class Main():
    def __init__(self):
        self.filename = f"{Path.home()}/tasks.csv"
        self.columns = ['Submitted', 'Due', 'Estimate', 'Priority', 'Name']

    def init_tasks(self):
        with open(self.filename, "w") as f:
            f.write("\t".join(self.columns))
            f.write("\n")

    def read_tasks(self, mapper: DataMapper):
        self.data_mapper = mapper
        csv = pd.read_csv(self.filename, delimiter="\t")
        # 1 means to operate on the rows, not the columns.
        csv["Time Remaining"] = csv.apply(self.data_mapper.map_submission, axis=1)
        csv["Adjusted Priority"] = csv.apply(self.data_mapper.map_adjusted_priority, axis=1)
        csv = csv.sort_values(by=['Adjusted Priority'])
        csv["Sprint"] = csv["Estimate"].apply(self.data_mapper.map_sprints)
        self.data_mapper.sprint_manager.reset()
        csv["Confidence"] = csv.apply(self.data_mapper.map_sprint_confidence, axis=1)
        csv["On track"] = csv["Confidence"].apply(self.data_mapper.map_on_track())
        csv["Submitted"] = csv.apply(self.data_mapper.map_human_time_submitted, axis=1)
        csv["Due"] = csv.apply(self.data_mapper.map_human_time_due, axis=1)
        return csv

    def append_tasks(self, row: Row):
        with open(self.filename, "a") as csv_file:
            writer = csv.writer(csv_file, delimiter="\t", quotechar='|')
            writer.writerow([row.submitted, row.due, row.estimate, row.priority, row.name])


if __name__ == '__main__':
    main()
