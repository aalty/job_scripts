#!/bin/bash
srun ior -a POSIX -w -B -t 3m -b 20g -o /tmp/testFile
