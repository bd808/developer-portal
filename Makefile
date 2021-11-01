# Copyright (c) 2021 Wikimedia Foundation and contributors.
# All Rights Reserved.
#
# This file is part of Wikimedia Developer Portal.
#
# Wikimedia Developer Portal is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Wikimedia Developer Portal is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Wikimedia Developer Portal.  If not, see <http://www.gnu.org/licenses/>.

this := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
PROJECT_DIR := $(dir $(this))
PIPELINE_DIR := $(PROJECT_DIR)/.pipeline
BLUBBEROID := https://blubberoid.wikimedia.org
DOCKERFILES := $(PIPELINE_DIR)/local.Dockerfile

help:
	@echo "Make targets:"
	@echo "============="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'
.PHONY: help

start: $(DOCKERFILES) ## Start the docker-compose stack
	docker compose up --build --detach
.PHONY: start

stop:  ## Stop the docker-compose stack
	docker compose stop
.PHONY: stop

restart: stop start  ## Restart the docker-compose stack
.PHONY: restart

status:  ## Show status of the docker-compose stack
	docker compose ps
.PHONY: status

shell:  ## Get an interactive shell inside the container
	docker compose exec portal bash
.PHONY: shell

tail:  ## Tail logs from the docker-compose stack
	docker compose logs -f
.PHONY: tail

build:  ## Build static site
	docker compose exec portal \
		poetry run mkdocs --verbose build
.PHONY: tail

clean:  ## Clean up Docker images and containers
	yes | docker image prune
	yes | docker container prune
.PHONY: clean

%.Dockerfile: $(PIPELINE_DIR)/blubber.yaml
	echo "# Dockerfile for *local development*." > $@
	echo "# Generated by Blubber from .pipeline/blubber.yaml" >> $@
	curl -sH 'content-type: application/yaml' --data-binary @$^ \
	$(BLUBBEROID)/v1/$(*F) >> $@
