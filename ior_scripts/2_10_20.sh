#!/bin/bash
srun ior -a POSIX -w -B -t 10m -b 20g -o /tmp/testFile
