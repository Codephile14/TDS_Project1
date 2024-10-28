#!/bin/bash

TOKEN="***********************************"
AUTH_HEADER="Authorization: token $TOKEN"
BASE_URL="https://api.github.com"

# Input and output files
USER_FILE="users.csv"
REPO_FILE="repositories.csv"

# Initialize CSV files with headers for repositories
echo "login,full_name,created_at,stargazers_count,watchers_count,language,has_projects,has_wiki,license_name" > $REPO_FILE

# Function to fetch repository details for a user
get_user_repositories() {
  local username=$1
  local page=1
  local per_page=100
  local count=0

  while [ $count -lt 500 ]; do
    repos=$(curl -s -H "$AUTH_HEADER" "$BASE_URL/users/$username/repos?sort=pushed&per_page=$per_page&page=$page")
    
    # Debug output to check the response
    echo "API Response for user \"$username\" (Page $page): $repos"

    # Check if the response is valid JSON
    if ! echo "$repos" | jq . > /dev/null 2>&1; then
        echo "Error fetching repos for user \"$username\": Invalid JSON response"
        echo "$repos"  # Print the response for debugging
        return  # Exit the function early
    fi
    
    # Check if there are any repositories
    if [ "$(echo "$repos" | jq '. | length')" -eq 0 ]; then
      break
    fi
    
    # Parse and write repository details to CSV
    echo "$repos" | jq -r --arg username "$username" '
      .[] | [
        $username,
        .full_name,
        .created_at,
        .stargazers_count,
        .watchers_count,
        .language,
        .has_projects,
        .has_wiki,
        (.license | .key // "None")
      ] | @csv' >> $REPO_FILE

    count=$((count + per_page))
    page=$((page + 1))
  done
}

# Read each user from users.csv and fetch their repositories
while IFS=, read -r login _; do
  # Skip the header row
  if [[ "$login" == "login" ]]; then
    continue
  fi
  
  # Trim quotes and whitespace from the username
  login=$(echo "$login" | tr -d '"' | xargs)

  # Fetch repositories for the user and write to repositories.csv
  echo "Fetching repositories for user: \"$login\""
  get_user_repositories "$login"

  sleep 1  # Respect API rate limits
done < "$USER_FILE"

echo "Repository data collection complete. Check $REPO_FILE for results."
