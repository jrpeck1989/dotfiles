# Snowplow Development Functions
# Functions specific to Snowplow development workflow

# =============================================================================
# Snowplow Micro Functions
# =============================================================================

function run_micro() {
    local WATCHED_DIR="$HOME/Documents/snowplow-micro/example"
    local IMAGE_NAME="snowplow/snowplow-micro:2.3.0"
    local CONTAINER_NAME="micro"
    local WATCHER_PID

    # Cleanup function to be called on exit
    function cleanup() {
        echo -e "\nStopping processes..."
        # Kill the file watcher if it's running
        if [[ -n "$WATCHER_PID" ]]; then
            kill "$WATCHER_PID" 2>/dev/null
        fi
        # Stop the docker container
        docker stop "$CONTAINER_NAME" &>/dev/null || true
        echo "Cleanup complete. Exiting."
    }

    # Set up trap to call cleanup on script exit (Ctrl+C)
    trap cleanup INT TERM EXIT

    # Start the file watcher in the background.
    # When it detects a change, it just stops the container,
    # which will cause the 'docker logs' command to exit and the main loop to restart.
    (fswatch -o "$WATCHED_DIR" | while read -r; do
        echo -e "\n--- Change detected, restarting container ---"
        docker stop "$CONTAINER_NAME" >/dev/null
    done) &
    WATCHER_PID=$!

    # Main loop
    while true; do
        echo "Starting container '$CONTAINER_NAME'..."
        docker run --rm -d --name "$CONTAINER_NAME" -p 9090:9090 \
            --mount type=bind,source="$WATCHED_DIR/enrichments",destination=/enrichments \
            --mount type=bind,source="$WATCHED_DIR",destination=/config \
            "$IMAGE_NAME" >/dev/null

        # Check if the container started successfully
        if ! docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
            echo "Error: Container failed to start."
            # Wait before trying again
            sleep 5
            continue
        fi

        echo "Tailing logs... (Press Ctrl+C to exit)"
        # This command will block until the container is stopped
        docker logs -f "$CONTAINER_NAME"
        
        # Add a small delay to prevent rapid looping if 'docker logs' exits unexpectedly
        sleep 1
    done
}

function run_micro_dev() {
    # 1. Dependency checks
    if ! command -v fswatch &> /dev/null; then
        echo "Error: fswatch is not installed. Please install it to continue." >&2
        echo "On macOS, you can run: brew install fswatch" >&2
        return 1
    fi

    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Please install it to continue." >&2
        return 1
    fi

    # 2. Configuration and path checks
    local watched_dir="./example"
    if [[ ! -d "$watched_dir" ]]; then
        echo "Error: Directory to watch ('$watched_dir') not found." >&2
        echo "Please make sure you are in the root of the 'snowplow-micro' project directory." >&2
        return 1
    fi
    local image_name="snowplow/snowplow-micro:2.3.0"
    local container_name="snowplow-micro-dev"
    local watcher_pid

    # 3. Cleanup function for graceful shutdown
    function cleanup() {
        echo -e "\n\nSIGINT received, shutting down..."
        
        # Disable the trap to prevent re-entrant calls
        trap - INT TERM

        # Stop the file watcher
        if [[ -n "$watcher_pid" ]] && ps -p "$watcher_pid" > /dev/null; then
            echo "Stopping file watcher (PID: $watcher_pid)..."
            kill "$watcher_pid" 2>/dev/null
        fi

        # Stop and remove the Docker container
        echo "Stopping and removing Docker container '$container_name'..."
        if docker ps -a -q --filter "name=$container_name" | grep -q .; then
            docker rm -f "$container_name" > /dev/null
        fi
        
        echo "Shutdown complete. Goodbye!"
        # Exit the script with a standard code for interruption
        return 130
    }

    trap cleanup INT TERM

    # 4. Initial cleanup of any orphaned container
    echo "Checking for and removing any old '$container_name' containers..."
    if docker ps -a -q --filter "name=$container_name" | grep -q .; then
        docker rm -f "$container_name" > /dev/null
    fi

    # 5. Start file watcher
    echo "Watching for file changes in '$watched_dir'..."
    # -o batches events, -r is for recursive watching.
    fswatch -or "$watched_dir" | while read -r event_path; do
        echo "-> File change detected: $event_path"
        echo "   Restarting Snowplow Micro container..."
        if docker ps -q --filter "name=$container_name" | grep -q .; then
            docker stop "$container_name" > /dev/null
        fi
    done &
    watcher_pid=$!

    # 6. Main loop to run and monitor Docker container
    while true; do
        echo "Starting Snowplow Micro container '$container_name'..."
        docker run \
            --rm \
            -d \
            --name "$container_name" \
            -p 9090:9090 \
            --mount type=bind,source="$(pwd)/$watched_dir/enrichments",destination=/enrichments \
            --mount type=bind,source="$(pwd)/$watched_dir",destination=/config \
            "$image_name" > /dev/null

        if ! docker ps -q --filter "name=$container_name" | grep -q .; then
            echo "Error: Container '$container_name' failed to start." >&2
            echo "Will retry in 5 seconds..."
            sleep 5
            continue
        fi

        echo "Container started. Tailing logs... (Ctrl+C to stop)"
        
        # Block and stream logs. When container is stopped, this command will exit.
        docker logs -f "$container_name"

        # If the loop continues (e.g., container was stopped by fswatch), wait a moment.
        # This also prevents fast-spinning loops if the container fails instantly.
        sleep 0.5
    done
}
