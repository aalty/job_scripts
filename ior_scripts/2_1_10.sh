#!/bin/bash
srun ior -a POSIX -w -B -t 1m -b 10g -o /tmp/testFile
