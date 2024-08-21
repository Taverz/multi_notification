
#!/bin/bash

# Function to log errors
log_error() {
    local MESSAGE=$1
    echo "ERROR: $MESSAGE" >&2
}

# Obtain the access token
ACCESS_TOKEN=$(./get_access_token.sh | grep "Access Token:" | awk '{print $3}')

if [ -z "$ACCESS_TOKEN" ]; then
    log_error "Failed to obtain access token"
    exit 1
fi

# List of device FCM tokens
DEVICE_TOKENS=(
    # "dFxxxxxx:APA91bG9cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1"
    "dMBBYg4sROW6gMI2YD02hD:APA91bHJTJb0pD0C7PsWrtYnWd2nBrEZb5DS3wGraRtcHIgzc8N0gyPU149IopQy4XXciabtlBgJideuXyVyKXuO5YjvrysAMe1De34KoC80Y5YUXzCuHv0Mpkj5pNITucxyqftdDRu4"
    # Add more tokens as needed
)

# Notification payload
TITLE="Test Notification"
BODY="This is a test notification sent via shell script"
SOUND="default"

# Function to send push notification
send_push_notification() {
    local TOKEN=$1
    local RESPONSE

    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/json" -d '{
      "to": "'"$TOKEN"'",
      "notification": {
        "title": "'"$TITLE"'",
        "body": "'"$BODY"'",
        "sound": "'"$SOUND"'"
      },
      "data": {
        "key1": "value1",
        "key2": "value2"
      }
    }' https://fcm.googleapis.com/fcm/send)

    # Extract the HTTP status code and response body
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

    echo "Response for token $TOKEN:"
    echo "HTTP Status: $HTTP_STATUS"
    echo "Response Body: $RESPONSE_BODY"
    echo "-----------------------------"

    # Check if HTTP status indicates success
    if [ "$HTTP_STATUS" -ne 200 ]; then
        log_error "Failed to send notification to $TOKEN: HTTP Status $HTTP_STATUS"
        return 1
    fi

    return 0
}

# Main function to send notifications
send_notifications() {
    for TOKEN in "${DEVICE_TOKENS[@]}"
    do
        echo "Sending notification to $TOKEN"
        send_push_notification "$TOKEN"
        if [ $? -ne 0 ]; then
            log_error "Error occurred while sending notification to $TOKEN"
        fi
    done

    echo "All notifications processed."
}

# Run the main function
send_notifications
