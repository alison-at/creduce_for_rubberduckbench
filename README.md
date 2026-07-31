__Creduce for RubberDuckBench: Proof Of Concept

This repository preserves the inital experiment of using Creduce to reduce codebases down to code relevant to RubberDuckBench Code Understanding questions. 

The initial RubberDuckBench codebase used for the proof-of-concept is RubberDuckBench Python 5.

Repository Organization:

`creduce_for_rubberduckbench/python_5_example/code_to_reduce` contains the three files relevant to the RubberDuckBench Python 5 understanding benchmark. 

`creduce_for_rubberduckbench/python_5_example/creduce_test` contains the scripts to reduce only `corpus_pruning_task.py`, or `corpus_pruning_task.py`and `engine_common.py`, and finally all three relevant files. 

`python_5_example/expected_reduced_output` contains the ideal reduced control and dataflow. 

`creduce_for_rubberduckbench/python_5_example/scripts` contains the script to restore the reduced files to their original state to rerun tests. 
