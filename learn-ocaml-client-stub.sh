#!/usr/bin/env bash

srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

echo >&2 'Warning: the learn-ocaml-client binary is missing.'
echo >&2 'Please put the proper binary inside the directory:'
echo >&2 "'$srcdir'"

exit 1
