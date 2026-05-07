import os
   
def get_value(environment_variable ):
  value_string = os.getenv(environment_variable)
  return value_string
