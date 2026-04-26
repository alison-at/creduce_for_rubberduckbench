This repository contains the python wheel, the code files, and the creduce bash tests to reduce the Clusterfuzz codebase to the RubberDuckBench-relevant questions.


__Creduce Script Structure__

RubberDuckBench Python 5 relies on tracking the dataflow of the `build_directory` variable. 

In order to run Creduce, corpus_pruning_task.py must be runnable. In order for corpus_pruning_task.py to be runnable, its imports must be resolvable. There are three options to resolve imports.
1. Comment out the imports
2. Create stubs for the imports in your test file
3. Install the original imports to the test environment. 

#3 is the preferred option to preserve as much original behavior as possible. The .whl file can be installed by running `pip install <wheel>.whl` in the test environment.

In order to get corpus_pruning_task.py to use the imports installed to the system,
everything added to `site-packages` has to be added to the system path using the line:

    site_packages = next(p for p in sys.path if "site-packages" in p)
    sys.path.insert(0, os.path.join(site_packages, "python")).

In my experience, the packages from the wheel are installed at `site-packages/python/".

I began this proof-of-concept by only reducing corpus_pruning_task.py, where the relevant dataflow begins (see ./reduce_test/reduce_corpus.sh). I realized that environment.py was also relevant to the dataflow, so I replaced the system wheel installed `environment` module with the environment.py file which defines the system module(see ./reduce_test/reduce_corpus_and_env.sh). 

    spec_env = importlib.util.spec_from_file_location(
        "system.environment", "environment.py"
    )
    envmod = importlib.util.module_from_spec(spec_env)
    spec_env.loader.exec_module(envmod)

    sys.modules["system.environment"] = envmod

This was the same general pattern I used to insert the engine_common.py file to resolve the `engine_common` import to corpus_pruning_task.py for my final script which reduced corpus_pruning_task.py, environment.py, and engine_common.py in one pass (see ./reduce_test/reduce_corpus_env_eng.sh).

By replacing imported modules with the actual code files and passing these files to the reducer along with the importing file, a test script which only calls the importing file will also reduce the imported files down to the relevant code.

__Skipping Creduce Passes__

Creduce reduces as much as possible and also performs lexical reduction to remove all scripts and variables names. The option `--remove-pass <pass name>` is the best way to avoid specific overly stringent passes. Running creduce should look like:
`creduce <test file> <file1 file2 ... fileN> <--remove-pass <pass name>> `.

Occasionally, for certain files I have to run ` --remove-pass pass_line_markers` to get creduce to run properly.