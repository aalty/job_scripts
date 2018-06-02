#!/bin/bash
srun ior -a POSIX -w -B -t 5m -b 20g -o /tmp/testFile
