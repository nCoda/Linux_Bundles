
FUJIAN_RELEASE=`cat FUJIAN_RELEASE`
JULIUS_RELEASE=`cat JULIUS_RELEASE`
LYCHEE_RELEASE=`cat LYCHEE_RELEASE`
NCODA_RELEASE=`date +'%y%m-%d.%H%M'`

WORK_DIR=/root/workdir
REPO_DIR=repos
REPO_PATH=$(WORK_DIR)/$(REPO_DIR)
VENV_DIR=ncoda-venv
VENV_PATH=$(WORK_DIR)/$(VENV_DIR)
REQUIREMENTS_FILE=requirements.txt
REQUIREMENTS_PATH=$(WORK_DIR)/$(REQUIREMENTS_FILE)
PEX_FILE=fujian.pex
PEX_PATH=$(WORK_DIR)/$(PEX_FILE)
HTTP_ARCHIVE_DIR=ncoda-http
HTTP_ARCHIVE_PATH=$(WORK_DIR)/$(HTTP_ARCHIVE_DIR)
PACKAGER_OUTPUT_ROOT_PATH=$(REPO_PATH)/julius/build
PACKAGER_OUTPUT_PATH=$(PACKAGER_OUTPUT_ROOT_PATH)/nCoda-linux-x64
ELECTRON_ARCHIVE_DIR=ncoda-electron
ELECTRON_ARCHIVE_PATH=$(PACKAGER_OUTPUT_ROOT_PATH)/$(ELECTRON_ARCHIVE_DIR)
SOURCE_VENV=source $(VENV_PATH)/bin/activate
HGDEMO_ARCHIVE_PATH=$(WORK_DIR)/hgdemo-201802.xz
HGDEMO_OUTPUT_DIR=programs


help:
	@echo "hi!"

circle-cache-key:
	@echo `date +'%y%m'` > circle-cache-key

clone-repos:
	@echo "Cloning the repositories..."
	mkdir -p $(REPO_DIR)
	-git clone --depth 1 https://github.com/nCoda/fujian.git -b $(FUJIAN_RELEASE) $(REPO_PATH)/fujian
	-git clone --depth 1 https://github.com/nCoda/julius.git -b $(JULIUS_RELEASE) $(REPO_PATH)/julius
	-git clone --depth 1 https://github.com/nCoda/lychee.git -b $(LYCHEE_RELEASE) $(REPO_PATH)/lychee
	cd $(REPO_PATH)/julius; \
	git submodule init; \
	git submodule update

build-venv:
	@echo "Building the virtualenv..."
	virtualenv $(VENV_PATH)
	$(SOURCE_VENV); \
	pip install $(REPO_PATH)/lychee; \
	pip install $(REPO_PATH)/fujian; \
	pip freeze > $(REQUIREMENTS_PATH)
	python3 -c "import re;q=open('$(REQUIREMENTS_PATH)');w=q.read();q.close();w=re.sub(r'Fujian\=\=.*', '$(REPO_PATH)/fujian', w);q=open('$(REQUIREMENTS_PATH)','w');q.write(w);q.close()"
	python3 -c "import re;q=open('$(REQUIREMENTS_PATH)');w=q.read();q.close();w=re.sub(r'Lychee\=\=.*', '$(REPO_PATH)/lychee', w);q=open('$(REQUIREMENTS_PATH)','w');q.write(w);q.close()"
	$(SOURCE_VENV); \
	pip install pex

finish-ncoda:
	@echo "Finishing the 'ncoda' script..."
	cp ncoda_script ncoda
	sed -i s/APP_RELEASE\ \=\ \'\?\?\?\'/APP_RELEASE\ \=\ \'$(NCODA_RELEASE)\'/ ncoda
	sed -i s/FUJIAN_RELEASE\ \=\ \'\?\?\?\'/FUJIAN_RELEASE\ \=\ \'$(FUJIAN_RELEASE)\'/ ncoda
	sed -i s/JULIUS_RELEASE\ \=\ \'\?\?\?\'/JULIUS_RELEASE\ \=\ \'$(JULIUS_RELEASE)\'/ ncoda
	sed -i s/LYCHEE_RELEASE\ \=\ \'\?\?\?\'/LYCHEE_RELEASE\ \=\ \'$(LYCHEE_RELEASE)\'/ ncoda

build-pex:
	@echo "Building the PEX file..."
	$(SOURCE_VENV); \
	pex -m fujian -r $(REQUIREMENTS_PATH) -o $(PEX_PATH)

install-julius:
	@echo "Installing JavaScript dependencies..."
	cd $(REPO_PATH)/julius; \
	yarn; \
	yarn add electron-packager

build-julius:
	@echo "Building a Julius release..."
	cd $(REPO_PATH)/julius; \
	yarn run build

archive-http:
	@echo "Archiving HTTP-based package..."
	mkdir -p $(HTTP_ARCHIVE_PATH)
	cp -R $(PACKAGER_OUTPUT_PATH)/resources/app/* $(HTTP_ARCHIVE_DIR)
	cp fujian.pex $(HTTP_ARCHIVE_PATH)
	cp ncoda $(HTTP_ARCHIVE_PATH)
	chmod +x $(HTTP_ARCHIVE_PATH)/ncoda
	mkdir -p $(HTTP_ARCHIVE_PATH)/$(HGDEMO_OUTPUT_DIR)
	tar -xJf $(HGDEMO_ARCHIVE_PATH) -C $(HTTP_ARCHIVE_PATH)/$(HGDEMO_OUTPUT_DIR)
	cd $(WORK_DIR); \
	tar -cJf $(HTTP_ARCHIVE_PATH).xz $(HTTP_ARCHIVE_DIR)

archive-electron:
	@echo "Archiving Electron-based package..."
	cp fujian.pex $(PACKAGER_OUTPUT_PATH)
	cp ncoda $(PACKAGER_OUTPUT_PATH)
	chmod +x $(PACKAGER_OUTPUT_PATH)/ncoda
	mkdir -p $(PACKAGER_OUTPUT_PATH)/$(HGDEMO_OUTPUT_DIR)
	tar -xJf $(HGDEMO_ARCHIVE_PATH) -C $(PACKAGER_OUTPUT_PATH)/$(HGDEMO_OUTPUT_DIR)
	mv $(PACKAGER_OUTPUT_PATH) $(ELECTRON_ARCHIVE_PATH)
	cd $(PACKAGER_OUTPUT_ROOT_PATH); \
	tar -cJf $(WORK_DIR)/$(ELECTRON_ARCHIVE_DIR).xz $(ELECTRON_ARCHIVE_DIR)


PHONY: .circle-cache-key .build .clone-repos .build-venv .build-pex .build-julius .archive-http .archive-electron
