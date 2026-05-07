import engine_common
import environment
class CorpusPruningException(Exception):
  ""
class Runner:
  def __init__(self, build_directory, context):
    self.build_directory = build_directory
    
    self.target_path = engine_common.find_fuzzer_path(
        build_directory, context)
    if not self.target_path:
      raise CorpusPruningException
  def get_build_dir(self):
    return self.build_directory
    
    
def do_corpus_pruning(context, last_execution_failed, revision):
  build_directory = environment.get_value('BUILD_DIR')
  runner = Runner(build_directory, context)
  return runner
