#!/bin/sh

zip -r -o -X -ll atun_$(cat module.prop | grep 'version=' | awk -F '=' '{print $2}').zip ./ -x '.git/*' -x 'build.sh' -x '.github/*' -x 'atun.json'
