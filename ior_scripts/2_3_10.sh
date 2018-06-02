#!/bin/bash
srun ior -a POSIX -w -B -t 3m -b 10g -o /tmp/testFile
