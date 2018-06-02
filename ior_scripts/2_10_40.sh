#!/bin/bash
srun ior -a POSIX -w -B -t 10m -b 40g -o /tmp/testFile
