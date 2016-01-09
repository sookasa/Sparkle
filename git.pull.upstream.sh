#!/bin/bash -
#=======================================================================
#
#   DESCRIPTION: Pull upstream code
#  REQUIREMENTS: git
#       COMPANY: Sookasa Inc.
#      REVISION: 1.0
#=======================================================================

SCRIPT=`basename $0`
DIR=`dirname $0`

# default configuration
url=https://github.com/sparkle-project/Sparkle
name=upstream
branch=master
commit=""

USAGE="Usage:\n\t $0 [url] [branch] [commit]"
EXAMPLE="Example:\n\t $0 $url $branch $commit"

while getopts ":hu:b:c:" opt; do
  case ${opt} in
    h )
        echo "$USAGE"
        echo "$EXAMPLE"
        exit 0
        ;;
    u )
        url=$OPTARG
        ;;
    b )
        branch=$OPTARG
        ;;
    c ) commit=$OPTARG
        ;;
    \? )
        echo "Invalid option: $OPTARG" 1>&2
        exit 1
        ;;
  esac
done
shift $((OPTIND -1))

# print params
echo "-I- url:    $url"
echo "-I- branch: $branch"
echo "-I- commit: $commit"
echo ""

# check prerequisites
which -s git || { echo "-E- git not found"; exit 1; }

# remove previous configuration
_url=`git remote -v | grep ^$name | grep \(fetch\)$ | awk '{print $2}' 2>&1`
git remote remove $name &> /dev/null && \
    { echo  "-I- Removed exisitng $_url"; }

# add new remote branch as upstream
git remote add $name $url && \
    { echo "-I- Added $name => $url"; } || \
    { echo "-E- Failed to add: $url"; exit 1; }

# pull it, and report result
echo "-I- Pulling $url $branch:"
git fetch $name $branch || { echo "-E- Failed to git fetch"; exit 1; }
git merge $commit       || { echo "-E- Failed to git merge";  exit 1; }

rc=$? && test $rc -eq 0 && echo "-I- Pulled successfully" || echo "-E- Failed!"

# handover (git merge) result
exit $rc
