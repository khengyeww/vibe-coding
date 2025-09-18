#!/bin/bash
# Usage:
#   ./s3-upload.sh <bucket-url> <file> [profile]
#
# Example:
#   ./s3-upload.sh s3://my-bucket-name ./release.zip
#   ./s3-upload.sh s3://my-bucket-name ./release.zip my-profile

set -e

bucket_url="$1"
file="$2"
profile="$3"

# 1️⃣ Require at least bucket and file arguments
if [ -z "$bucket_url" ] || [ -z "$file" ]; then
    echo "❌ Error: bucket URL and file are required."
    echo "👉 Usage: $0 <bucket-url> <file> [profile]"
    exit 1
fi

# Check file exists
if [ ! -f "$file" ]; then
    echo "❌ File not found: $file"
    exit 1
fi

# 2️⃣ Prepare profile option if provided
profile_opt=${profile:+--profile $profile}

# 3️⃣ Function to check AWS access
check_aws_access() {
    if ! aws s3 ls "$bucket_url" $profile_opt >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

# 4️⃣ If AWS access fails, attempt login
if ! check_aws_access; then
    # Replace `saml2aws` with your AWS login CLI
    login_cmd="saml2aws login --skip-prompt --session-duration=28800"
    # Use profile if set, otherwise default profile
    [ -n "$profile" ] && login_cmd+=" --profile $profile"

    echo "⚠️ AWS session may be expired. Attempting login${profile:+ for profile '$profile'}..."
    $login_cmd

    # Re-check after login
    if ! check_aws_access; then
        echo "❌ Cannot access bucket after login. Check AWS credentials and permissions."
        exit 1
    fi
fi

# 5️⃣ Upload file
echo "📤 Uploading $file to $bucket_url..."
aws s3 cp --quiet "$file" "$bucket_url" $profile_opt
echo "✅ Upload complete"
