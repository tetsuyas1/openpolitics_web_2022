FROM node:14-buster-slim as node
FROM ruby:2.7-slim-buster
ENV LANG C.UTF-8

COPY --from=node /opt/yarn-v* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  apt-transport-https \
  build-essential \
  pkg-config \
  libpq-dev \
  libxml2-dev \
  libxslt-dev \
  python \
  shared-mime-info \
  libfontconfig1 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Mecab導入時はコメントアウトを外してください（.circleci/config.ymlも要修正）
# WORKDIR /
# RUN apt-get update -qq && \
# apt-get install -y --no-install-recommends \
# sudo  \
# libmecab2  \
# libmecab-dev  \
# mecab   \
# mecab-ipadic   \
# mecab-ipadic-utf8   \
# mecab-utils \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
# WORKDIR /opt
# RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
# WORKDIR /opt/mecab-ipadic-neologd
# RUN bin/install-mecab-ipadic-neologd -n -y -p /var/lib/mecab/dic/mecab-ipadic-neologd
# RUN sed -i -e "s/debian/mecab-ipadic-neologd/" /etc/mecabrc

RUN mkdir /app
WORKDIR /app
COPY \
  Gemfile \
  Gemfile.lock \
  package.json \
  yarn.lock \
  /app/
RUN gem install bundler -v 1.17.2 && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle install -j3 && \
  find /usr/local/bundle -path '*/gems/*/ext/*/Makefile' -exec dirname {} \; | xargs -n1 -P$(nproc) -I{} make -C {} clean

RUN yarn install && yarn cache clean

COPY . /app

# assets precompile
# RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile \
# && yarn cache clean \
# && rm -rf node_modules tmp/cache

