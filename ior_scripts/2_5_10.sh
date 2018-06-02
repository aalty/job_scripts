#!/bin/bash
srun ior -a POSIX -w -B -t 5m -b 10g -o /tmp/testFile
