#!/usr/bin/python3

"""Gooo.

Usage:
  gob.py [<branch>]
  gob.py (-h | --help)
  gob.py --version

Options:
  -h --help     Show this screen.
  --version     Show version.

"""

from docopt import docopt

if __name__ == '__main__':
    arg = docopt(__doc__, version='get-orign-branch 1.0')

import git
from git import Repo
import os

import subprocess

def my_git_branch():

    cmd = []
    cmd.append('git')
    cmd.append('branch')
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    output = p.communicate()[0].split(b"\n")

    branch_list = []

    for _branch in output:
        _branch = _branch.decode('utf-8').replace('*', '').strip()
        if _branch != '':
            branch_list.append(_branch)

    return branch_list


def my_git_get_origin_branch(_branch):
    cmd = ['git', 'log', '--pretty=%d', '-n 1']
    i = 0
    while 1:
        commit = _branch + "~" + str(i)
        cmd.append(commit)

        p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        out = p.communicate()[0].decode('utf-8').strip().split(',')

        # print (out)
        # TODO remote -v not only origin
        for _line in out:
            _line=_line.strip().replace('(', '').replace(')', '')
            # print (_line)
            a = _line.split('/')
            # if 'tag:' in _line:
            #     # print("found tag")
            #     return commit, _line
            if a[0] == 'origin':
            # if '(origin' in _line:
                # print("found orign")
                cmd = a[1]

                return 'git push origin HEAD:refs/for/' + cmd + '%topic=power'

        if (i > 100):
            print("Too much patch !!")
            exit(0)

        i += 1
        del cmd[-1]



def get_active_branch(repo):
    return str(Repo(os.getcwd()).active_branch)


repo = git.Git(os.getcwd())

branch = arg['<branch>']

if (branch is None):
    branch = get_active_branch(repo)

print(my_git_get_origin_branch(branch))


