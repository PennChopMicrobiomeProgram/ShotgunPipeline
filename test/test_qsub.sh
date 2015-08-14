#!/bin/bash
export NO_QSUB=1

pipeline-qsub/submit.sh 123 .

unset NO_QSUB
