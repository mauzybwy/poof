# Build stage
FROM debian:bookworm-slim AS build

# Install dependencies for mise and building
RUN apt-get update -y && apt-get install -y \
    build-essential git curl ca-certificates \
    libssl-dev libncurses5-dev autoconf m4 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

# Copy mise config and install tools
COPY mise.toml ./
RUN mise trust && mise install

# Activate mise for subsequent commands
SHELL ["mise", "x", "--", "/bin/bash", "-c"]

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN env
RUN mix deps.compile

# Compile and build release
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/
RUN mix release

# Build assets
COPY assets assets
COPY priv priv
RUN mix assets.deploy

# Runtime stage - no mise needed, just the release
FROM debian:bookworm-slim AS runtime

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

WORKDIR /app

RUN useradd --create-home app
USER app

COPY --from=build --chown=app:app /app/_build/prod/rel/poof ./

ENV PHX_SERVER=true
CMD ["bin/poof", "start"]
