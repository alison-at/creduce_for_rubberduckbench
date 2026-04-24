__Explaination of Preserved Code__
The .whl contains all of the modules from clusterfuzz. 

Only three modules relevant for RubberDuckBench questions are kept as reducable files. 

All clusterfuzz modules can be installed with the command `pip install clusterfuzz_local-0.1.0-py3-none-an.whl}`

This is to avoid having to create stubs when trying to reduce clusterfuzz files which import other clusterfuzz modules. Creduce requires that the files be runnable in order to reduce them, so imports must be commented out, stubed, or resolvable.