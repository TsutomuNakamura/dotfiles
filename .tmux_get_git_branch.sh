#!/bin/bash
branch_name=$(git -C "#{pane_current_path}" --abbrev-ref HEAD 2>&-)
[ ! -z ${branch_name} ] && echo "⭠ ${branch_name}"
