#!/bin/env/bash

bundle exec cap -T

bundle exec cap staging deploy
bundle exec cap production deploy

bundle exec cap production deploy --dry-run
bundle exec cap production deploy --prereqs
bundle exec cap production deploy --trace
