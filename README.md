# Medical Imaging Flake

A nix flake based environment that can be used as a starting point for medical imaging data science projects.
The environment contains R, python, jupyter, a suite of tools for working with medical imaging files, pytorch and tensorflow with
GPU support enabled. The environment can be compiled into a Docker container for portability to places that don't have Nix.
To get started with the environment you need nix installed with flakes enabled.

With that a new project can be initialized as simply as:

```sh
mkdir my-awesome-project
cd my-awesome-project
nix flake init -t github:LKS-CHART/medical-imaging-nix
nix develop #on a large shared machine you might want to run nix --cores=<some number> develop
```

the first time you run this it will take a very long time, because it will build most of the software universe from
scratch for you, including pytorch and tensorflow, let it run overnight. But after that all subsequent calls
to nix develop will drop you into your shiny new environment. If you're ready to package up your environment into
a container you can run:

```sh
nix build .#docker
```

this takes a bit of time, so maybe start it before your next meeting.

And if you want to protect the packages in your environment from garbage collection you can
run:

```sh
nix build
```
