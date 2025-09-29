# Docker Utility Functions
# Collection of Docker-related helper functions

# =============================================================================
# Docker Cleanup Functions
# =============================================================================

# Removes all closed / exited Docker Containers
function docker-rmc() {
  echo "Removing all stopped Docker containers..."
  docker ps -a -q | while read id; do 
    if [[ -n "$id" ]]; then
      docker rm $id
    fi
  done
  echo "Cleanup complete."
}

# Removes all partial and dangling docker images (note: run docker-rmc first to remove links)
function docker-rmi() {
  echo "Removing dangling Docker images..."
  docker images -f "dangling=true" -q | while read id; do 
    if [[ -n "$id" ]]; then
      docker rmi $id
    fi
  done
  echo "Image cleanup complete."
}

# Combined Docker cleanup function
function docker-cleanup() {
  echo "Starting comprehensive Docker cleanup..."
  docker-rmc
  docker-rmi
  
  # Remove unused networks
  echo "Removing unused networks..."
  docker network prune -f
  
  # Remove unused volumes
  echo "Removing unused volumes..."
  docker volume prune -f
  
  echo "Docker cleanup completed!"
}
