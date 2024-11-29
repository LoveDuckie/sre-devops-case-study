#!/usr/bin/env bash

awk -F[/:] '{
    # Extract the domain
    if ($2 ~ /^http/) {
        sub(/^www\./, "", $3)
        domain = $3
    } else {
        sub(/^www\./, "", $1)
        domain = $1
    }
    # Split domain into parts
    split(domain, parts, ".")
    n = length(parts)

    # Dynamically determine multi-level TLDs
    if (n >= 3 && (length(parts[n]) <= 3 && length(parts[n-1]) <= 3)) {
        # If the last two segments are short (likely TLDs), include 3rd-to-last part
        print parts[n-2] "." parts[n-1] "." parts[n]
    } else if (n >= 2) {
        # Otherwise, use last two segments
        print parts[n-1] "." parts[n]
    }
}' file.txt | sort -u
