#!/usr/bin/env bash

# Calculate the cutoff date (2 months ago) in YYYY-MM-DD format
CUTOFF_DATE=$(date -d "2 months ago" +%Y-%m-%d)

echo "Looking for Docker images created before: $CUTOFF_DATE"
echo "--------------------------------------------------------"

# Loop through all local Docker images
docker images --format "{{.ID}}\t{{.CreatedAt}}\t{{.Repository}}:{{.Tag}}" | while read -r line; do
    # Extract fields from the formatting
    IMAGE_ID=$(echo "$line" | cut -f1)
    CREATED_DATE=$(echo "$line" | cut -f2 | sed 's/ UTC$//')
    IMAGE_NAME=$(echo "$line" | cut -f3)

    # Convert dates to Unix timestamps for clean comparison
    IMAGE_TS=$(date -d "$CREATED_DATE" +%s)
    CUTOFF_TS=$(date -d "$CUTOFF_DATE" +%s)

    # Compare timestamps
    if [ "$IMAGE_TS" -lt "$CUTOFF_TS" ]; then
        echo "Deleting: $IMAGE_NAME ($IMAGE_ID) | Created: $CREATED_DATE"

        # Remove the image. Force flag (-f) bypasses containers using it.
        docker rmi -f "$IMAGE_ID" > /dev/null 2>&1
    fi
done

echo "--------------------------------------------------------"
echo "Cleanup complete."
