# http://stackoverflow.com/a/23324703
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# run tests, linters, etc.
check: lint test

lint:
	flake8 ocflib

test: autoversion
	coverage erase
	coverage run -m py.test tests
	coverage report --show-missing

release-pypi: clean autoversion
	python3 setup.py sdist
	twine upload dist/*


builddeb: autoversion
	python3 setup.py sdist
	py2dsc --with-python2 False --with-python3 True dist/ocflib-*.tar.gz
	cd deb_dist/ocflib-*/ && dpkg-buildpackage -us -uc

clean:
	python3 setup.py clean
	rm -rf dist deb_dist

# PEP440 sets restrictions on public version schemes which prohibit appending a
# SHA; unfortunately, PyPI enforces this restriction
autoversion:
	date +%Y.%m.%d.%H.%M > .version

# Install Python versions using pyenv, run tests with tox.
tox-pyenv: export PYENV_ROOT := $(ROOT_DIR)/.pyenv
tox-pyenv: export PATH := $(PYENV_ROOT)/shims:$(PYENV_ROOT)/bin:${PATH}
tox-pyenv: .pyenv/ autoversion
	pyenv rehash
	tox

.pyenv/: export PYENV_ROOT := $(ROOT_DIR)/.pyenv
.pyenv/: export PATH := $(PYENV_ROOT)/shims:$(PYENV_ROOT)/bin:${PATH}
.pyenv/:
	git clone https://github.com/yyuu/pyenv.git .pyenv
	pyenv install 3.2.6
	pyenv install 3.4.3
	pyenv local 3.4.3 3.2.6
