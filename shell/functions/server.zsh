# Server Utility Functions
# Functions for running various development servers

# =============================================================================
# HTTP Server Functions
# =============================================================================

function run-server() {
    trap 'cleanup' INT

    function cleanup() {
        echo "Shutting down server and freeing up port 8888..."
        kill $!
        wait $! 2>/dev/null
        echo "Server on port 8888 has been stopped."
        exit 0
    }

    echo "Starting HTTP server on port 8888..."
    echo "Serving from: $HOME/Developer/dev"
    echo "Press Ctrl+C to stop the server"
    
    http-server $HOME/Developer/dev -p 8888 &
    wait
}

function https-server() {
    local cert_path="$HOME/.localhost-ssl/localhost.crt"
    local key_path="$HOME/.localhost-ssl/localhost.key"
    
    # Check if SSL certificates exist
    if [[ ! -f "$cert_path" || ! -f "$key_path" ]]; then
        echo "Error: SSL certificates not found at $HOME/.localhost-ssl/"
        echo "Please generate SSL certificates first:"
        echo "  mkdir -p ~/.localhost-ssl"
        echo "  # Generate certificates using mkcert or openssl"
        return 1
    fi
    
    echo "Starting HTTPS server with SSL certificates..."
    echo "Press Ctrl+C to stop the server"
    
    trap 'kill $!' EXIT
    http-server --ssl --cert "$cert_path" --key "$key_path"
}

function run-micro-and-server() {
    echo "Starting Snowplow Micro and HTTP server..."
    echo "Press Ctrl+C to stop both services"
    
    trap 'kill $PID1 $PID2' EXIT
    (start_micro &)
    (run-server &)
}
