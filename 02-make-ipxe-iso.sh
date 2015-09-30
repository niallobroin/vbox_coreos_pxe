#!/usr/bin/bash

set -ex

rm -f ipxe.iso; cd ipxe/src/; make bin/ipxe.iso EMBED=../../localhost.ipxe; cd ../..; mv ipxe/src/bin/ipxe.iso .




