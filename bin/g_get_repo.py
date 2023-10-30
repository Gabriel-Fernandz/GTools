#!/usr/bin/env python3
import subprocess

process = subprocess.run(['git','config', '--get', 'remote.origin.url'], check=False, stdout=subprocess.PIPE, universal_newlines=True)

repo = process.stdout.strip('\n').split('/')[-1]
# if repo == "":
# 	repo = process.stdout.strip('\n').split('/')[-2]

DIC_REPOS = {}

DIC_REPOS['tfa'] = ['tfa', 'tf-a', 'arm-trusted-firmware']
DIC_REPOS['tfm'] = ['tfm', 'tf-m', 'trusted-firmware-m']
DIC_REPOS['uboot'] = ['u-boot']
DIC_REPOS['optee'] = ['optee', ]
DIC_REPOS['kernel'] = ['linux']

def check_repos(_repo):
	for r in DIC_REPOS:
		# print (r)
		for x in DIC_REPOS[r]:
			# print ('--> ', x)
			if x in _repo:
				return r

	return ""

print(check_repos(repo))
