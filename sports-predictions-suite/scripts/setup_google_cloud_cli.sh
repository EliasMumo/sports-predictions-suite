#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PROJECT_ID=kevobike-3dd72 REGION=us-central1 ./scripts/setup_google_cloud_cli.sh

PROJECT_ID="${PROJECT_ID:-kevobike-3dd72}"
REGION="${REGION:-us-central1}"

echo "==> Validating CLI tools"
command -v gcloud >/dev/null
command -v firebase >/dev/null

echo "==> Setting active project"
gcloud config set project "$PROJECT_ID"
firebase use "$PROJECT_ID" --add || true

echo "==> Enabling required Google Cloud APIs"
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  firebase.googleapis.com \
  firebaserules.googleapis.com \
  firestore.googleapis.com \
  secretmanager.googleapis.com

echo "==> Printing active config"
gcloud config list --format='text(core.project,core.account)'

echo "==> Done. Next deploy functions from functions/"
echo "firebase deploy --only functions --project $PROJECT_ID"
