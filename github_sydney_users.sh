#!/bin/bash

TOKEN="*******************************************"
AUTH_HEADER="Authorization: token $TOKEN"
BASE_URL="https://api.github.com"
SEARCH_URL="$BASE_URL/search/users?q=location:Sydney+followers:>100&per_page=100"

# Output CSV file
OUTPUT_FILE="users.csv"

# Write CSV header
echo "login,name,company,location,email,hireable,bio,public_repos,followers,following,created_at" > $OUTPUT_FILE

# Function to get detailed information of a user
get_user_details() {
  local username=$1
  curl -s -H "$AUTH_HEADER" "$BASE_URL/users/$username" | jq -r '
    {
      login: .login,
      name: .name,
      company: (.company // "" | gsub("^@"; "") | ascii_upcase),
      location: .location,
      email: .email,
      hireable: .hireable,
      bio: .bio,
      public_repos: .public_repos,
      followers: .followers,
      following: .following,
      created_at: .created_at
    } | [
      .login, .name, .company, .location, .email, .hireable, .bio, 
      .public_repos, .followers, .following, .created_at
    ] | @csv'
}

# Get list of users
page=1
while true; do
  # Query GitHub API for users in Sydney with >100 followers
  response=$(curl -s -H "$AUTH_HEADER" "$SEARCH_URL&page=$page")
  
  # Extract usernames from the response
  usernames=$(echo "$response" | jq -r '.items[].login')
  
  # Stop if no more users found
  if [ -z "$usernames" ]; then
    break
  fi
  
  # Fetch and save each user's detailed info
  for username in $usernames; do
    get_user_details "$username" >> $OUTPUT_FILE
    sleep 1  # Respect API rate limits
  done

  # Proceed to the next page
  ((page++))
done

echo "Data collection complete. Check $OUTPUT_FILE for results."
