#!/usr/bin/env python
"""
MultiReport for Quartet Metabolomics QC
"""

from setuptools import setup, find_packages

version = '1.1.1'

setup(
  name = 'quartet_metabolite_report',
  version = version,
  author = 'Yaqing Liu',
  author_email = 'liuyaqing@outlook.com',
  description = 'MultiReport for Quartet Metabolomics QC.',
  long_description = __doc__,
  keywords = 'bioinformatics',
  url = 'https://github.com/clinico-omics/quartet-metabolite-report',
  download_url = 'https://github.com/clinico-omics/quartet-metabolite-report/releases',
  license = 'MIT',
  packages = find_packages(),
  include_package_data = True,
  install_requires = [
    'multiqc==1.11',
    'plotly==4.9.0',
    'pandas==1.1.0'
  ],
  entry_points = {
    'multiqc.modules.v1': [
      'data_generation_information = quartet_metabolite_report.modules.data_generation_information:MultiqcModule',
      'conclusion = quartet_metabolite_report.modules.conclusion:MultiqcModule',
      'snr = quartet_metabolite_report.modules.snr:MultiqcModule',
      'correlation = quartet_metabolite_report.modules.correlation:MultiqcModule',
      'supplementary = quartet_metabolite_report.modules.supplementary:MultiqcModule'
    ],
    'multiqc.hooks.v1': [
      'execution_start = quartet_metabolite_report.custom_code:quartet_metabolite_report_execution_start'
    ],
    'multiqc.cli_options.v1': [
      'disable_plugin = quartet_metabolite_report.cli:disable_plugin'
    ],
    'multiqc.templates.v1': [
      'quartet_metabolite_report = quartet_metabolite_report.templates.default'
    ]
  },
  classifiers = [
    'Development Status :: 4 - Beta',
    'Environment :: Console',
    'Environment :: Web Environment',
    'Intended Audience :: Science/Research',
    'License :: OSI Approved :: MIT License',
    'Natural Language :: English',
    'Operating System :: MacOS :: MacOS X',
    'Operating System :: POSIX',
    'Operating System :: Unix',
    'Programming Language :: Python',
    'Programming Language :: JavaScript',
    'Topic :: Scientific/Engineering',
    'Topic :: Scientific/Engineering :: Bio-Informatics',
    'Topic :: Scientific/Engineering :: Visualization',
  ],
)