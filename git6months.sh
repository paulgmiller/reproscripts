#!/bin/bash


# Initialize counters
total_insertions=0
total_deletions=0
count 

# List of commit hashes to ignore
ignore_commits=("4d33c24046bd021f64287fca90a40dabe11ff64e" "91862727ac21135f027ed4837202721c2be83b02")

# Function to check if a commit is in the ignore list
should_ignore_commit() {
    local commit=$1
    for ignore_commit in "${ignore_commits[@]}"; do
        if [[ "$commit" == "$ignore_commit" ]]; then
            return 0 # true, should ignore
        fi
    done
    return 1 # false, should not ignore
}

# Process each commit made by the user within the last 6 months
git log --since="7 months ago" --author="$(git config user.name)" --pretty=format:"%H" | while read commit_hash
do

    if should_ignore_commit "$commit_hash"; then
        echo "Skipping commit: $commit_hash"
        continue
    fi

    # Get diff stats for each commit, parse insertions and deletions
    stats=$(git diff --stat $commit_hash^ $commit_hash | tail -n1)
    # Extract insertions and deletions using regex and add them to the total
    if [[ $stats =~ ([0-9]+)\ insertions* ]] 
    then 
        insertions=${BASH_REMATCH[1]}
        export total_insertions=$(expr $total_insertions + $insertions)
    fi
    
    if [[ $stats =~ ([0-9]+)[[:space:]]deletions* ]]
    then 
        deletions=${BASH_REMATCH[1]}
        export total_deletions=$(expr $total_deletions + $deletions)
    fi

    #echo "$commit_hash $(expr $insertions -  $deletions)"
    
    # Output the results
    echo "Total insertions: $total_insertions"
    echo "Total deletions: $total_deletions"
done
