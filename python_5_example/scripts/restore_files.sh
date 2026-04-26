#!/bin/bash
set -e

if [ -f ../creduce_test/environment.py.orig ]; then
    cp -f ../creduce_test/environment.py.orig ../code_to_reduce/environment.py
fi

if [ -f ../creduce_test/corpus_pruning_task.py.orig ]; then
    cp -f ../creduce_test/corpus_pruning_task.py.orig ../code_to_reduce/corpus_pruning_task.py
fi

if [ -f ../creduce_test/engine_common.py.orig ]; then
    cp -f ../creduce_test/engine_common.py.orig ../code_to_reduce/engine_common.py
fi

echo "Files restored successfully."