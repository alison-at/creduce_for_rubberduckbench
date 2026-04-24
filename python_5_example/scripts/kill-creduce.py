#!/usr/bin/env python3
#This kills the creduce process just as creduce runs clex rename tokens, which strips the reduced files of the original variable names
import subprocess
import sys

cmd = ["creduce"] + sys.argv[1:]

proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    bufsize=1
)

for line in proc.stdout:
    print(line, end="")

    if "rename-toks" in line:
        print("Detected rename-toks pass. Terminating...")
        proc.terminate()
        proc.wait()
        sys.exit(1)

proc.wait()