#!/bin/echo Please run this file with the source command
# Deploy a python virtual environment for ShotgunPipeline
#
# After this code is sourced, virtualenv and virtualenvwrapper should
# be installed, and a new virtual environment, shotgun-pipeline,
# should be activated.
#
# To work in the virtual environment for future sessions, you need to
# define the variables PATH, PYTHONPATH, and WORKON_HOME as below.
# After this, you need to source the virtualenvwrapper.sh script,
# located in $PIP_BIN.  It is best to do these things in your .bashrc
# file. The indicated section below can be copied/pasted directly into
# .bashrc for this purpose.
#
# In future sessions, after the varibales are correctly defined and
# virtualenvwrapper.sh is sourced, the virtual environment may be
# activated with the command "workon shotgun-pipeline".
#
# Pre-requisites not included in deployment:
# python (>= 2.7.3)
# pip

set -x

# Don't set -e because we are sourcing this script

# Don't set -u because several variables may legitimately be undefined
# as of first use, such as PYTHONPATH and others in virtualenvwrapper.sh

pip install --user --upgrade virtualenv
pip install --user --upgrade virtualenvwrapper

####################################################
## BASH CONFIG SECTION
## This section should be added to your .bashrc file

# See here for paths used by pip install --user
# http://stackoverflow.com/questions/7143077
PLATFORM=`uname`
if [ "$PLATFORM" == "Darwin" ]; then
    PIP_BIN="$HOME/Library/Python/2.7/bin"
    PIP_LIB="$HOME/Library/Python/2.7/lib/python/site-packages"
else
    PIP_BIN="$HOME/.local/bin"
    PIP_LIB="$HOME/.local/lib/python2.7/site-packages"
fi

# Add the pip install directories to PATH and PYTHONPATH
export PATH="${PIP_BIN}:$PATH"
export PYTHONPATH="${PIP_LIB}:$PYTHONPATH"

# Initialize virtualenvwrapper
export WORKON_HOME="$HOME/.virtualenvs"
source "${PIP_BIN}/virtualenvwrapper.sh"

## END BASH CONFIG SECTION
####################################################

virtualenv "${WORKON_HOME}/shotgun-pipeline"
source "${WORKON_HOME}/shotgun-pipeline/bin/activate"

set +x
