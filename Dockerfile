# FROM elixir:1.10-alpine as build
# FROM elixir:1.10 as build
FROM elixir:1.10

# Install Elixir & Erlang environment dependencies
# RUN apk add --no-cache make gcc g++ git openssh cyrus-sasl-dev krb5 krb5-dev krb5-libs libsasl
# RUN apt-get update && apt-get install libsasl2-dev

# Build sasl2 for Kerberos/GSSAPI support
RUN curl -S -O -L https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.27/cyrus-sasl-2.1.27.tar.gz \
  && tar xaf cyrus-sasl-2.1.27.tar.gz \
  && cd cyrus-sasl-2.1.27 \
  && ./configure --prefix=/usr \
  && make \
  && make install

RUN mix local.hex --force
RUN mix local.rebar --force

ENV MIX_ENV=prod
WORKDIR /opt/sites/rig

# Copy release config
COPY version /opt/sites/rig/
COPY rel /opt/sites/rig/rel/
COPY vm.args /opt/sites/rig/

# Copy necessary files for dependencies
COPY mix.exs /opt/sites/rig/
COPY mix.lock /opt/sites/rig/

# Install project dependencies and compile them
RUN mix deps.get && mix deps.compile && mix deps.clean mime --build

# COPY deps/brod_gssapi /opt/sites/rig/deps/brod_gssapi

# Copy application files
COPY config /opt/sites/rig/config
COPY lib /opt/sites/rig/lib

# Compile and release application production code
RUN mix compile
RUN mix distillery.release

# FROM erlang:22-alpine
# FROM erlang:23

LABEL org.label-schema.name="Reactive Interaction Gateway"
LABEL org.label-schema.description="Reactive API Gateway and Event Hub"
LABEL org.label-schema.url="https://accenture.github.io/reactive-interaction-gateway/"
LABEL org.label-schema.vcs-url="https://github.com/Accenture/reactive-interaction-gateway"

#RUN apk add --no-cache bash krb5 openssl librdkafka librdkafka-dev
#RUN apk add --no-cache cyrus-sasl-gssapiv2

# experimenting with sasl and gssapi ================================
# RUN apk add --no-cache alpine-sdk git python-dev py-pip py-cffi krb5

# # change to edge alpine branch to install librdkafka package
# RUN sed -i -e 's/v3\.4/edge/g' /etc/apk/repositories \
#     && apk upgrade --update-cache --available \
#     && apk add --no-cache librdkafka librdkafka-dev

# RUN apk add --no-cache bash libsasl
# # ===================================================================

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Build sasl2 for Kerberos/GSSAPI support
# RUN curl -S -O -L https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.27/cyrus-sasl-2.1.27.tar.gz \
#   && tar xaf cyrus-sasl-2.1.27.tar.gz \
#   && cd cyrus-sasl-2.1.27 \
#   && ./configure --prefix=/usr \
#   && make \
#   && make install

# WORKDIR /opt/sites/rig
# COPY --from=build /opt/sites/rig/_build/prod/rel/rig /opt/sites/rig/

RUN apt-get install libgssapi-krb5-2 libkrb5-3 libkrb5support0

# Proxy
EXPOSE 4000
# Internal APIs
EXPOSE 4010

# CMD trap exit INT; trap exit TERM; /opt/sites/rig/bin/rig foreground & wait
# CMD /opt/sites/rig/bin/rig foreground
WORKDIR /opt/sites/rig/_build/prod/rel/rig
CMD ./bin/rig foreground
