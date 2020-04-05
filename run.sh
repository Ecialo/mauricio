#!/usr/bin/env bash

export TG_TOKEN="token"
export CAT_API_TOKEN="cat_token"
export DOG_API_TOKEN="dog_token"
export APP_NAME="mauricio"
export MIX_ENV="prod"

mix release --overwrite
# mix distillery.release --env=prod --verbose
_build/prod/rel/mauricio/bin/mauricio start
