FROM coqorg/base:bare

WORKDIR /home/coq

# Install GNU Emacs (tty)
RUN sudo apt-get update -y -q \
  && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -q --no-install-recommends \
    ca-certificates \
    curl \
    emacs25-nox \
    locales \
  && sudo sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
  && sudo locale-gen \
  && sudo update-locale LANG=en_US.UTF-8 \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/*
  
ENV COMPILER="4.05.0"

RUN ["/bin/bash", "--login", "-c", "set -x \
  && opam init --auto-setup --yes --jobs=${NJOBS} --compiler=${COMPILER} --disable-sandboxing \
  && eval $(opam env) \
  && opam update -y \
  # BEGIN opam libs
  && opam install -y -v -j ${NJOBS} ocamlfind \
  # TODO Manuel à compléter
  && opam config list && opam repo list && opam list \
  && opam clean -a -c -s --logs"]

COPY --chown=coq:coq .emacs .emacs

ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

# Do some automatic Emacs installation/byte-compilation:
RUN emacs --batch -l "${HOME}/.emacs"

ENV PATH /home/coq/bin:/home/coq/.local/bin:${PATH}

COPY --chown=coq:coq learn-ocaml-client-stub.sh /home/coq/.local/bin/learn-ocaml-client

CMD ["/bin/bash"]
