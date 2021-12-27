all: install-report install-metqc
	@echo "Compile the metqc"
	@lein uberjar
	@printf "\n\n\e[1;32mRun the command for more details: \nsource .env/bin/activate\njava -jar target/uberjar/quartet-metqc-report-*-standalone.jar -h\e[0m"

clean:
	rm -rf report/dist report/quartet_metabolite_report.egg-info metqc.tar.gz

make-env:
	virtualenv -p python3 .env
	cp resources/bin/metqc.sh .env/bin

install-report: make-env
	. .env/bin/activate
	cd report && python3 setup.py sdist && pip3 install dist/*.tar.gz

install-metqc:
	tar czvf metqc.tar.gz metqc
	R CMD INSTALL metqc.tar.gz
