#!/bin/bash

# Function to log errors
log_error() {
    local MESSAGE=$1
    echo "ERROR: $MESSAGE" >&2
}

# Your service account details
PROJECT_ID="chulpaninsurance"
PRIVATE_KEY_ID="bdbac378a12c201fe3ed510e0cbc54d6ffa1a39e"
PRIVATE_KEY=$(echo "" | sed 's/\\n/\n/g')
CLIENT_EMAIL="firebase-adminsdk-3aczq@chulpaninsurance.iam.gserviceaccount.com"
TOKEN_URI="https://oauth2.googleapis.com/token"

# Create JWT header
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Create JWT claim set
CURRENT_TIME=$(date +%s)
EXPIRY_TIME=$(($CURRENT_TIME + 3600))
CLAIM_SET=$(echo -n "{\"iss\":\"$CLIENT_EMAIL\",\"scope\":\"https://www.googleapis.com/auth/firebase.messaging\",\"aud\":\"$TOKEN_URI\",\"exp\":$EXPIRY_TIME,\"iat\":$CURRENT_TIME}" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Create the JWT
JWT="$HEADER.$CLAIM_SET"

# Sign the JWT with the private key
SIGNED_JWT=$(echo -n "$JWT" | openssl dgst -sha256 -sign <(echo -e "$PRIVATE_KEY") | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Combine the JWT and the signature to create the final JWT
FINAL_JWT="$JWT.$SIGNED_JWT"

# Request an access token
RESPONSE=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$FINAL_JWT" $TOKEN_URI)

# Extract the access token
ACCESS_TOKEN=$(echo $RESPONSE | grep -oP '"access_token":\s*"\K[^"]+')

if [ -z "$ACCESS_TOKEN" ]; then
    log_error "Failed to obtain access token"
    exit 1
else
    echo "Access Token: $ACCESS_TOKEN"
fi
