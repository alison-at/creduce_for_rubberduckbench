set -e
python3 <<'PY'
import importlib.util
import sys

import random
import types
import os
import site

#for some reason, this workst to point the path to the wheel-installed packages
site_packages = next(p for p in sys.path if "site-packages" in p)
sys.path.insert(0, os.path.join(site_packages, "python"))

#this system is the clusterfuzz system module
import system
print("\nsystem file is: " + system.__file__)

import bot.fuzzers

filename = "corpus_pruning_task.py"


spec_env = importlib.util.spec_from_file_location(
    "system.environment", "environment.py"
)
envmod = importlib.util.module_from_spec(spec_env)
spec_env.loader.exec_module(envmod)

sys.modules["system.environment"] = envmod

system.environment = envmod

spec_eng = importlib.util.spec_from_file_location("bot.fuzzers.engine_common", "engine_common.py")
engmod = importlib.util.module_from_spec(spec_eng)
spec_eng.loader.exec_module(engmod)

sys.modules["bot.fuzzers.engine_common"] = engmod
bot.fuzzers.engine_common = engmod

#import corpus pruning file as module
spec = importlib.util.spec_from_file_location("mod", filename)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


#had to add ROOT_DIR=None
#had to import pip install psutil

#fake dummpy corpus - ai generated
class DummyCorpus:
    def get_gcs_url(self): return "url"
    def rsync_from_disk(self, path): pass

class DummyFuzzTarget:
    binary = "fuzz_bin"
    def project_qualified_name(self): return "proj"

class DummyContext:
    fuzz_target = DummyFuzzTarget()
    corpus = DummyCorpus()
    quarantine_corpus = DummyCorpus()
    cross_pollinate_fuzzers = []
    cross_pollination_method = "method"
    tag = "tag"

    initial_corpus_path = "/tmp/in"
    minimized_corpus_path = "/tmp/out"
    bad_units_path = "/tmp/bad"
    quarantine_corpus_path = "/tmp/quarantine"

    def sync_to_disk(self): pass
    def sync_to_gcs(self): pass
    def restore_quarantined_units(self): pass

ctx = DummyContext()

dynamic_build_dir = os.path.join(
    os.getcwd(),
    str(os.getpid())  # opaque to creduce/static reasoning
)

print("build dir: "+ dynamic_build_dir)
os.environ['BUILD_DIR'] = dynamic_build_dir
os.environ['OS_OVERRIDE'] = "fuchsia"

#sys.platform = 'FUCHSIA'#set for engine_common.find_fuzzer_path predictable result

if not hasattr(mod, "do_corpus_pruning"):
    sys.exit(1)

print("Runner exists:", hasattr(mod, "Runner"))

if not hasattr(mod, "CorpusPruningException"):
    print("no corpus pruning exception")
    sys.exit(1)

ctx = DummyContext()

cp_exception = mod.CorpusPruningException()

#TEST 1: Set BUILD_DIR to None, expect a CorpusPruningException
os.environ.pop('BUILD_DIR', None)

failed_none = False
try:
    mod.do_corpus_pruning(ctx, False, "r1")
except mod.CorpusPruningException:
    failed_none = True
    print("got cp exception")

#TEST 2: Set BUILD_DIR to be a dynamic value that creduce cannot predict, expect valid result
os.environ['BUILD_DIR'] = dynamic_build_dir

failed_valid = False
try:
    result_valid = mod.do_corpus_pruning(ctx, False, "r1")
except mod.CorpusPruningException:
    failed_valid = True

if not (failed_none and not failed_valid):
    sys.exit(1)

#TEST 3: Given that do_corpus_pruning() returns a valid result, check that the result is the expected result
result = mod.do_corpus_pruning(ctx, last_execution_failed=False, revision="r1")

expected = os.environ['BUILD_DIR']

if (result.get_build_dir() != expected):
    sys.exit(1)



'''
#TEST 4: Check that the Runner(build_directory=None) returns a CorpusPruningException
failed_runner = False
try:
    mod.Runner(None, ctx)
except mod.CorpusPruningException:
    failed_runner = True

if not failed_runner:
    sys.exit(1)
'''

print("done")
sys.exit(0)
PY