#!/bin/bash
srun ior -a POSIX -w -B -t 10m -b 10g -o /tmp/testFile
