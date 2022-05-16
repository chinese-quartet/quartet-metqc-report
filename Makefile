all: clean make-env install-report install-metqc
	@echo "Compile the quartet-metqc-report...."
	@bin/lein uberjar
	@printf "\n\n\e[1;32mRun the command for more details: \nsource .env/bin/activate\njava -jar target/uberjar/quartet-metqc-report-*-standalone.jar -h\e[0m"

clean:
	@echo "Clean the environment..."
	@bin/lein clean
	@rm -rf .env .lsp .clj-kondo report/dist report/quartet_metabolite_report.egg-info metqc.tar.gz resources/renv/library resources/renv/staging

make-env:
	pip3 install virtualenv && virtualenv -p python3 .env
	cp resources/bin/metqc.sh .env/bin

install-report:
	cd report && ../.env/bin/python3 setup.py sdist && ../.env/bin/pip3 install dist/*.tar.gz

install-metqc:
	@Rscript -e 'install.packages("renv", repos="http://cran.us.r-project.org")'
	cp -R resources/* .env/
	@echo 'renv::activate(".env"); renv::restore();' > .env/Rprofile
	export R_PROFILE_USER=.env/Rprofile && Rscript -e 'renv::install("./metqc");'
