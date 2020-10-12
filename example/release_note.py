#!/usr/bin/env python3

output = []
def add(s1, s2):
    output.extend([s1, input(s2+": "), ""])
    print()

contacts = []
def add_contact(s1, s2):
    contacts.append(s1 + input(s2+": "))
    print()

tbl_affected = []
def add_table_row(l):
    tbl_affected.append(l)

if __name__ == '__main__':

    s_and_in = input("Does this affect Android? [yn]: ")
    s_and = "--"
    if s_and_in.upper() == 'Y':
        s_and = "A"
    s_ios_in = input("Does this affect iOS? [yn]: ")
    s_ios = "--"
    if s_ios_in.upper() == 'Y':
        s_ios = "A"

    add_table_row(["", "","WF US","WF CA","WF DE","WF UK","J&M","AM","Birch","Perigold", ""])
    add_table_row(["","--","--","--","--","--","--","--","--","--", ""])
    add_table_row(["","Desktop / Tablet","--","--","--","--","--","--","--","--", ""])
    add_table_row(["","Mobile Web","--","--","--","--","--","--","--","--", ""])
    add_table_row(["","iOS",s_ios,s_ios,s_ios,s_ios,s_ios,s_ios,s_ios,s_ios, ""])
    add_table_row(["","Android",s_and,s_and,s_and,s_and,s_and,s_and,s_and,s_and, ""])

    add("Purpose", "What was the problem and why did we have to make a change?")
    add("Summary","What did you do about it, in 3 sentences or less?")
    add("Release Date","Date deployed to production - [MM/DD/YYYY]")
    add("Details","Details - Context and technical details about the implementation")
    add("Screenshots","Any assets that you would like to link? Screenshots, doc files, etc")
    add("We’re Never Done","What’s next? Call out plans for specific platforms/stores/geos if applicable")
    add("Thank you!","Special Thanks?")

    add_contact("Engineering:", "Engineering Contact?")
    add_contact("Product:", "Product Contact?")
    add_contact("XD:", "XD Contact?")
    add_contact("Analytics:", "Analytics Contact?")
    add_contact("Find us on slack, #channelname", "Find us on slack, [#channelname]")

    print("##################################################\n\n")
    s_affected = "\n".join(['|'.join(x) for x in tbl_affected])
    s_out = "\n".join(output)
    s_contacts = "\n".join(contacts)
    print(
        f"{s_affected}"
        f"\n\n{s_out}"
        f"\nQuestions?"
        f"\n{s_contacts}",
        flush=True
    )

