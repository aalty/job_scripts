#!/bin/bash
srun ior -a POSIX -w -B -t 2m -b 20g -o /tmp/testFile
