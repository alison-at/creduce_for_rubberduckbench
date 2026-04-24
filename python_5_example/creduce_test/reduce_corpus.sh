set -e


python3 <<'PY'
import importlib.util
import sys
import random
import types
import os
import site
site_packages = next(p for p in sys.path if "site-packages" in p)

sys.path.insert(0, os.path.join(site_packages, "python"))

'''
sys.path.insert(0, "/python")
sys.path.insert(0, "/python/system")
sys.path.insert(0, "/appengine/python")
sys.path.insert(0, "/appengine/python/system")
'''
filename = "corpus_pruning_task.py"
'''
#this is to patch an error with python3.7 to python 3.13, python3.13 moved interable and collections
import collections
import collections.abc

collections.Iterable = collections.abc.Iterable

import collections
import collections.abc

collections.Mapping = collections.abc.Mapping
collections.Iterable = collections.abc.Iterable
'''

#import corpus pruning file as module
spec = importlib.util.spec_from_file_location("mod", filename)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

from system import environment

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

os.environ['BUILD_DIR'] = os.getcwd()
os.environ['OS_OVERRIDE'] = "fuchsia"
#sys.platform = 'FUCHSIA'#set for engine_common.find_fuzzer_path predictable result

if not hasattr(mod, "do_corpus_pruning"):
    sys.exit(1)

ctx = DummyContext()
result = mod.do_corpus_pruning(ctx, last_execution_failed=False, revision="r1")

print(result.get_build_dir())

if (result.get_build_dir() != os.getcwd()):
    sys.exit(1)

try:
    compare_runner = mod.Runner(None, ctx)

    if (compare_runner != None):
        sys.exit(0)
except:
    print("Build directory = None caused runner error")

print("done")
sys.exit(0)
PY