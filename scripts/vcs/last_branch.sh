#!/bin/bash

last_branch () 
{ 
    git branch --sort=committerdate
}

last_branch "$@"
