.PHONY: build-and-tag

build-and-tag:
	if [[ -z $$(docker images -q medical-imaging-nix:$$(git rev-parse --short=8 HEAD)) ]]; then \
	  nix build .\#docker; \
	  docker image load -i result; \
	  docker image tag test-docker:test medical-imaging-nix:$$(git rev-parse --short=8 HEAD); \
	else \
	  echo Image at tag medical-imaging-nix:$$(git rev-parse --short=8 HEAD) already exists; \
	fi

