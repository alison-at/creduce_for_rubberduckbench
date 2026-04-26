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

import system
#print("\nsystem file is: " + system.__file__)

filename = "corpus_pruning_task.py"


spec_env = importlib.util.spec_from_file_location(
    "system.environment", "environment.py"
)
envmod = importlib.util.module_from_spec(spec_env)
spec_env.loader.exec_module(envmod)

sys.modules["system.environment"] = envmod

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

ctx = DummyContext()
result = mod.do_corpus_pruning(ctx, last_execution_failed=False, revision="r1")

print(result.get_build_dir())

expected = os.environ['BUILD_DIR']

if (result.get_build_dir() != expected):
    sys.exit(1)

try:
    compare_runner = mod.Runner(None, ctx)

    if (compare_runner != None):
        sys.exit(0)
except:
    print("Build directory = None caused runner error")

try:

    os.environ['BUILD_DIR'] = "None"
    result_none = mod.do_corpus_pruning(ctx, last_execution_failed=False, revision="r1")

    print(result_none.get_build_dir())
    Sys.exit(1)
except Exception as e: 
    print(e)

print("done")
sys.exit(0)
PY