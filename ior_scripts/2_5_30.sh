#!/bin/bash
srun ior -a POSIX -w -B -t 5m -b 30g -o /tmp/testFile
