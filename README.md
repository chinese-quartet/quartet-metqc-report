# quartet-metqc-report

Visualizes Quality Control(QC) results for Quartet Project.

## Standlone Mode
### Prerequisite

- Bash
- Python3 >= 3.7
- virtualenv
- pip3
- R >= 3.6.3
### Installation

```
# Clone the repo
git clone https://github.com/chinese-quartet/quartet-metqc-report

cd quartet-metqc-report

# Build the environment and compile the quartet-metqc-report
make
```

### Usage

```bash
source .env/bin/activate
java -jar target/uberjar/quartet-metqc-report-*-standalone.jar -h
```

## Plugin Mode

### Prerequisite

Please access [Quartet Service](https://github.com/chinese-quartet/quartet-service) for more details 

### Installation

```bash
copm-cli install -n quartet-metqc-report -V v0.1.2 -d plugins
```

## Examples

...

## Contributions

- [MetQC](./metqc) developed by [Naixin Zhang](https://github.com/nxzhang)
- [MultiReport](./report) developed by [Yaqing Liu](https://github.com/lyaqing)

## License

Copyright © 2021

This program and the accompanying materials are made available under the
terms of the Eclipse Public License 2.0 which is available at
http://www.eclipse.org/legal/epl-2.0.

This Source Code may also be made available under the following Secondary
Licenses when the conditions for such availability set forth in the Eclipse
Public License, v. 2.0 are satisfied: GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or (at your
option) any later version, with the GNU Classpath Exception which is available
at https://www.gnu.org/software/classpath/license.html.
