#import pandas as pd
#import numpy as np
import argparse
import os
import sys
import subprocess
import pprint

def findtype(n):
	if n > 64:
		return ("int128_t","uint128_t")
	elif n > 32:
		return ("int64_t","uint64_t")
	elif n > 16:
		return ("int32_t","uint32_t")
	elif n > 8:
		return ("int16_t","uint16_t")
	else:
		return ("int8_t","uint8_t")

def callcpp(input,macros):
	r = subprocess.run(["gcc", "-E"] + ["-D%s=%s" % x for x in macros.items()] + [input], capture_output=True)
	if r.returncode == 0:
		return r.stdout
	else:
		print(r.stderr.decode("latin-1"))
		raise Exception(b"GCC " + r.stdout + b" " + r.stderr)

def bitshift(a,b):
	return a << b if b > 0 else a << -b;
def bitor(a,b):
	return a |b
def main():
	parser = argparse.ArgumentParser(description='Process some integers.')
	parser.add_argument('-n',type=int,default=8)
	parser.add_argument('-e',type=int,default=0)
	parser.add_argument('-p',default="")
	parser.add_argument('-o',default="-")
	parser.add_argument('-v','--verbose',action="store_true")
	args = parser.parse_args()

	if args.n not in (8,16,32):
		print("given bits not supportd, only 8 16 32:",args.n)
		return 

	st,ut = findtype(args.n)
	nst,nut = findtype(args.n*2)

	if args.e < 0 or args.e > args.n-2:
		print("given esbits not supported shall be [0,n-2]")
		return 

	if args.p == "":
		w = (args.n,args.e)
		if w == (8,0) or w == (16,1) or w == (32,2):
			args.p = "p%d" % args.n
		else:
			args.p = "p%d_%d" % w

	sm = hex(1 << args.n-1)
	ib = hex(1 << args.n-2)
	tm = hex(bitshift(bitor((1 << args.n-2),bitshift(1,args.n-3)),1))

	d = dict(clz="__builtin_clz",POSIT_NSTYPE=nst,POSIT_NUTYPE=nut,PREFIX=args.p,POSIT_STYPE=st,POSIT_UTYPE=ut,POSIT_NBITS=args.n,POSIT_SIGNMASK=sm,POSIT_INVBIT=ib,POSIT_TWICEMASK=tm,POSIT_ESBITS=args.e)
	if args.verbose:
		pprint.pprint(d)
	o = callcpp("anyposit.cl",d)
	o = o.decode("latin1").replace("\n\n","\n")
	o = """
#include <stdint.h>
#include <stdlib.h>
"""+o
	of = sys.stdout if args.o == "-" else open(args.o,"w")
	of.write(o)

	#POSIT_STYPE
	#POSIT_UTYPE
	#POSIT_NBITS
	#POSIT_SIGNMASK
	#POSIT_INVBIT
	#POSIT_TWICEMASK
	#clz --> __builtin_clz_

if __name__ == '__main__':
	main()