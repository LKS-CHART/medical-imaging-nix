.PHONY: build-and-tag

build-and-tag:
	nix build .\#docker
	docker image load -i result
	docker image tag test-docker:test medical-imaging-nix:$$(git rev-parse --short=8 HEAD)

