#!/bin/bash
srun ior -a POSIX -w -B -t 2m -b 10g -o /tmp/testFile
