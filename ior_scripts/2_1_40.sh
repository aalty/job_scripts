#!/bin/bash
srun ior -a POSIX -w -B -t 1m -b 40g -o /tmp/testFile
