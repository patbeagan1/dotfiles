#!/usr/bin/env python3

from github import Github

# using an access token
g = Github(
    # "access_token"
    )

for repo in g.get_user().get_repos():
    print(repo.name)
    repo.edit(has_wiki=False)
    # to see all the available attributes and methods
    print(dir(repo))