#!/bin/bash
srun ior -a POSIX -w -B -t 2m -b 30g -o /tmp/testFile
