#!/bin/bash
srun ior -a POSIX -w -B -t 5m -b 40g -o /tmp/testFile
