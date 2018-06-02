#!/bin/bash
srun ior -a POSIX -w -B -t 1m -b 30g -o /tmp/testFile
