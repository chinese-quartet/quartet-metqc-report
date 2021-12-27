#!/usr/bin/env python
""" quartet-metabolite-report plugin functions

We can add any custom Python functions here and call them
using the setuptools plugin hooks. 
"""

from __future__ import print_function
from pkg_resources import get_distribution
import logging

from multiqc.utils import report, util_functions, config

# Initialise the main MultiQC logger
log = logging.getLogger('multiqc')

# Save this plugin's version number (defined in setup.py) to the MultiQC config
config.quartet_metabolite_report_version = get_distribution('quartet_metabolite_report').version


# Add default config options for the things that are used in MultiQC_NGI
def quartet_metabolite_report_execution_start():
  """ Code to execute after the config files and
  command line flags have been parsedself.

  This setuptools hook is the earliest that will be able
  to use custom command line flags.
  """
  
  # Halt execution if we've disabled the plugin
  if config.kwargs.get('disable_plugin', True):
    return None

  log.info('Running Quartet Metabolomics MultiQC Plugin v{}'.format(config.quartet_metabolite_report_version))

  # Add to the main MultiQC config object.
  # User config files have already been loaded at this point
  # so we check whether the value is already set. This is to avoid
  # clobbering values that have been customised by users.

  # Module-data_generation_information
  if 'data_generation_information/information' not in config.sp:
    config.update_dict( config.sp, { 'data_generation_information/information': { 'fn_re': '.*general_information.*.json$' } } )
  
  # Module-conclusion
  if 'conclusion/conclusion_table' not in config.sp:
    config.update_dict( config.sp, { 'conclusion/conclusion_table': { 'fn_re': '^conclusion_table.csv$' } } )
  
  if 'conclusion/rank_table' not in config.sp:
    config.update_dict( config.sp, { 'conclusion/rank_table': { 'fn_re': '^rank_table.csv$' } } )
  
  # Module-snr
  if 'snr/table_met' not in config.sp:
    config.update_dict( config.sp, { 'snr/table_met': { 'fn_re': '^PCAtable.csv$' } } )
  
  # Module-correlation
  if 'correlation/table_met' not in config.sp:
    config.update_dict( config.sp, { 'correlation/table_met': { 'fn_re': '^CTRtable.csv$' } } )  
  
  config.module_order = ['data_generation_information', 'conclusion', 'snr', 'correlation', 'supplementary']
  config.log_filesize_limit = 2000000000