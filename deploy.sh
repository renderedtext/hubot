#!/bin/bash

deploy_tarball="$HOME/deploy_tarball.tar.gz"

heroku_base_url="https://api.heroku.com/apps/$HEROKU_APP_NAME"
heroku_sources_url="$heroku_base_url/sources"
heroku_builds_url="$heroku_base_url/builds"

function create_tarball() {
  echo " - Creating tarball"
  tar -zcf "$deploy_tarball" .

  echo "    tarball: $deploy_tarball"
}

function create_source_endpoint() {
  echo " - Creating source endpoint"

  curl -s -n -X POST "$heroku_sources_url" \
    -H 'Accept: application/vnd.heroku+json; version=3' \
    -H "Authorization: Bearer $HEROKU_API_KEY" > /tmp/sources.json

  get_url="$(cat /tmp/sources.json | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["source_blob"]["get_url"]' )"
  put_url="$(cat /tmp/sources.json | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["source_blob"]["put_url"]' )"

  echo "    get_url: $get_url"
  echo "    put_url: $put_url"
}

function upload_to_source_endpoint() {
  echo " - Uploading to source endpoint"
  curl -s "$put_url" -X PUT -H 'Content-Type:' --data-binary @$deploy_tarball
}

function create_build() {
  echo " - Creating a build"

  curl -s -n -X POST "$heroku_builds_url" \
    -d "{\"source_blob\":{\"url\":\"$get_url\", \"version\": \"$REVISION\"}}" \
    -H 'Accept: application/vnd.heroku+json; version=3.streaming-build-output' \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $HEROKU_API_KEY" > /tmp/deploy.json

  stream_url="$(cat /tmp/deploy.json | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["output_stream_url"]' )"
}

function stream_result() {
  echo " - Waiting for results"
  echo ""

  curl $stream_url
}

function main() {
  echo "Deployment via Heroku API"

  create_tarball
  create_source_endpoint
  upload_to_source_endpoint
  create_build
  stream_result
}

main
