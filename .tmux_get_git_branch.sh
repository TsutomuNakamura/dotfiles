#!/bin/bash -e
# Thank you for nice trick!
# http://qiita.com/koara-local/items/940ce66e2ecd8e4d8582
cd `tmux display-message -p -F "#{pane_current_path}"`
branch_name=`git branch | grep \*.* | sed -e 's/\*\ //'`
[ ! -z ${branch_name} ] && echo "⭠ ${branch_name}"
