#!/bin/bash
srun ior -a POSIX -w -B -t 3m -b 30g -o /tmp/testFile
