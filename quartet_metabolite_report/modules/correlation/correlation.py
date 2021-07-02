#!/usr/bin/env python

""" Quartet Metabolomics Report plugin module """

from __future__ import print_function
from collections import OrderedDict
import logging
from typing import List
import pandas as pd

from multiqc import config
from multiqc.plots import scatter
from multiqc.modules.base_module import BaseMultiqcModule

# Initialise the main MultiQC logger
log = logging.getLogger('multiqc')

class MultiqcModule(BaseMultiqcModule):
  def __init__(self):
        
    # Halt execution if we've disabled the plugin
    if config.kwargs.get('disable_plugin', True):
      return None
    
    # Initialise the parent module Class object
    super(MultiqcModule, self).__init__(
      name='Correlation with Reference Datasets',
      target='Relative correlation with reference datasets',
      #anchor='corr',
      #href='https://github.com/clinico-omics/quartet-metabolite-report',
      info=' metric which was representing the numerical consistency of the relative expression profiles.'
    )

    # Find and load any input files for correlation
    self.corr_pca_data = dict()

    corr_pca_table = []
    for f in self.find_log_files('correlation/table_met'):
      f_p = '%s/%s' % (f['root'], f['fn'])
      
      content = pd.read_csv(f_p)
      content["dataset_HMDBid"] = content["dataset"] + "_" + content["HMDB_id"]
      content = content.replace("other\nmetabolites", "other metabolites")
      
      self.types = {'other metabolites':'#999999', 'spike-ins':'#E41A1C'}
      
      keys = content.columns.to_list()
      for index,row in content.iterrows():
        corr_pca_table.append(dict(zip(keys, row)))
      
      for i in corr_pca_table:
        key = i['dataset_HMDBid']
        pop_i = i.pop('dataset_HMDBid')
        self.corr_pca_data[key] = i
    
    # Now add a Scatter plot
    if len(self.corr_pca_data) != 0:
      self.pca_plot()
    else:
      log.debug('No file matched: correlation - CTRtable.csv')

  def pca_plot(self):
    data = OrderedDict()

    # cycle over samples and add PC coordinates to data dict
    for s_name, d in self.corr_pca_data.items():
      data[s_name] = {
        "x": d["mean"],
        "y": d["re"],
        "color": self.types[d["type"]]
      }
    
    # generate section and plot
    if len(data) > 0:
      pconfig = {
        "id": "correlation_plot",
        "title": "Scatter Plot Based on Reference Dataset",
        "xlab": "Relative metabolic profiles in reference dataset",
        "ylab": "Measured ratios between samples",
        "marker_size": 3,
        "marker_line_width": 0,
      }

      self.add_section(
        name="",
        description = """Points are coloured as follows: 
        <span style="color: #E41A1C;">Spike-ins</span>, 
        <span style="color: #999999;">Other metabolites</span>.""",
        anchor="correlation-scatter",
        plot=scatter.plot(data, pconfig)
      )