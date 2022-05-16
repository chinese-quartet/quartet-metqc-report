#!/usr/bin/env python

""" Quartet Metabolomics Report plugin module """

from __future__ import print_function
import base64
import logging
from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule

# Initialise the main MultiQC logger
log = logging.getLogger('multiqc')

def read_image(image):
  with open(image, "rb") as image_file:
    encoded_string = base64.b64encode(image_file.read())
    return encoded_string.decode('utf-8')

class MultiqcModule(BaseMultiqcModule):
  def __init__(self):
        
    # Halt execution if we've disabled the plugin
    if config.kwargs.get('disable_plugin', True):
      return None
    
    # Initialise the parent module Class object
    super(MultiqcModule, self).__init__(
      name='Supplementary'
    )
    
    html = '''
      <!-- Methods -->
      <div class='methods'>
        <div class='small-12 columns'>
        <h3 class='section-header black'>Methods</h3>
        
        <p><b>1. Signal-to-Noise Ratio (SNR)</b>: We apply SNR in the reliability assessment of metabolome data based on the built-in biological differences between Quartet samples. SNR is the fraction of distances between different Quartet samples ("signal") and distances between technical replicates ("noise") on 2D-PCA scatter plot, where a high SNR indicates the tight clustering of technical and wide dispersion of different Quartet samples replicates, as well as good reproducibility and discriminability overall the batch level.</p>

        <p><b>2. Relative Correlation with Reference Datasets (RC)</b>: RC is used for assessment of quantitative consistency with the reference datasets (RDs) at relative levels. To evaluate the performance of both targeted and untargeted metabolomics, the RDs were established with historical datasets of high quality by benchmarking the relative abundance values for each sample pair (D5/D6, F7/D6, M8/D6) at metabolite abundance level. We calculate relative abundance values (ratios to D6) of the queried data for metabolites overlapped with the RDs. Then we calculate the Pearson correlation as RC of measured relative abundance values and those in the RDs.</p>

        <p><b>3. Recall of DAMs in Reference Datasets (Recall)</b>: Recall is used for qualitative assessment of the accuracy of biological difference detecting, as the fraction of the differential abundancial metabolites (DAMs) in RDs that are successfully retrieved. Here recall is the number of measured DAMs (p < 0.05, t test) divided by the number of DAMs should be identified as RDs.</p>
        </div>
      </div>
      
      <!-- Contact us -->
      <div class='contact'>
        <div class='small-12 columns'>
        <h3 class='section-header black'>Contact us</h3>
          <b>Fudan University Pharmacogenomics Research Center</b>
          <li>Project manager: Quartet Team</li>
          <li>Email: quartet@fudan.edu.cn</li>
        </div>
      </div>
      
      <!-- Disclaimer -->
      <div class='disclaimer'>
        <div class='small-12 columns'>
        <h3 class='section-header black'>Disclaimer</h3>
        <p>This quality control report is only for this specific test data set and doesn’t represent an evaluation of the business level of the sequencing company. This report is only used for scientific research, not for clinical or commercial use. We don’t bear any economic and legal liabilities for any benefits or losses (direct or indirect) from using the results of this report.</p>
        </div>
      </div>
      '''

    self.add_section(
      name = '',
      anchor = '',
      description = '',
      plot = html
    )