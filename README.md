---

![MultiReport for Quartet Metabolomics](multireport-logo.png)

---
**MultiReport is a plugin based on MultiQC, providing additional tools which are
specific to Metabolomics quality control of Quartet Project.**

For more information about Quartet Project, see http://chinese-quartet.org/

For more information about MultiQC, see http://multiqc.info

## Usage

To use this plugin, you need to install MultiQC and install `quartet-metabolite-report`.

```shell
# Install MultiQC
pip install multiqc

# Install quartet-metabolite-report
git clone https://github.com/clinico-omics/quartet-metabolite-report.git
cd quartet-metabolite-report
python setup.py install
```

*The input files for the MultiReport is the output result of `qcprot` (https://github.com/chinese-quartet/qcprot)*


Then, you can get the QC report by the following actions:

```shell
# E.g., save all data into the folder `results`
multiqc ./results/

# For the results which is not belong to Quartet Metabolomics pipeline, you can use the the original MultiQC
multiqc ./results/ --disable-plugin
```

## Development
If you're developing this code, you'll want to clone it locally and install
it manually instead of using `pip`:

```shell
git clone https://github.com/clinico-omics/quartet-metabolite-report.git
cd quartet-metabolite-report
# You don't need to rerun the installation every time you make an edit (though you still do if you change anything in setup.py).
python setup.py develop
```