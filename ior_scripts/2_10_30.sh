#!/bin/bash
srun ior -a POSIX -w -B -t 10m -b 30g -o /tmp/testFile
