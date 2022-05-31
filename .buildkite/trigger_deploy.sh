#!/bin/bash

set -euo pipefail

# Set up a variable to hold the meta-data from your block step
DEMO_NAME="$(buildkite-agent meta-data get demo_name)"
DEMO_IMAGE_TAG="$(buildkite-agent meta-data get image_tag)"

# Create a pipeline with your trigger step
PIPELINE="steps:
  - trigger: \"deploy-demos\"
    label: \"Trigger deploy\"
    build:
      meta_data:
        demo-name: "$DEMO_NAME"
        demo-image-tag: "$DEMO_IMAGE_TAG"
"

# Upload the new pipeline and add it to the current build
echo "$PIPELINE" | buildkite-agent pipeline upload