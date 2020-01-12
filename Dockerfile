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
  && opam install -y -v -j ${NJOBS} ocamlfind"]

# Installing learn-ocaml-client
RUN git clone https://github.com/ocaml-sf/learn-ocaml.git  
RUN sudo apt update 
RUN sudo apt install libssl-dev libev-dev -y

WORKDIR /home/coq/learn-ocaml 
RUN opam install . --deps-only --locked -y 
RUN opam install opam-installer -y 
RUN eval $(opam env) && make && make opaminstall 
RUN cp ~/.opam/4.05.0/bin/learn-ocaml-client /home/coq/.local/bin

WORKDIR /home/coq
RUN  rm -fr learn-ocaml 

# End install
RUN opam config list && opam repo list && opam list 
RUN opam clean -a -c -s --logs

COPY --chown=coq:coq .emacs .emacs

ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

# Do some automatic Emacs installation/byte-compilation:
RUN emacs --batch -l "${HOME}/.emacs"

ENV PATH /home/coq/bin:/home/coq/.local/bin:${PATH}

CMD ["/bin/bash"]
