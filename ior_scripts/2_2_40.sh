#!/bin/bash
srun ior -a POSIX -w -B -t 2m -b 40g -o /tmp/testFile
