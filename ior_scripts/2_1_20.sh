#!/bin/bash
srun ior -a POSIX -w -B -t 1m -b 20g -o /tmp/testFile
