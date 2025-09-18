#!/bin/bash
# Usage: ./git-tag.sh 1.2.34
# Deletes old tags (local & remote), pushes new tag to remote only.

set -e

VERSION="$1"
TARGET_BRANCH="main"

# 1️⃣ Check version argument
if [ -z "$VERSION" ]; then
  echo "❌ Error: Please provide a version number, e.g., 1.2.34"
  exit 1
fi

# 2️⃣ Get short git hash (8 chars)
GIT_HASH=$(git rev-parse --short=8 "$TARGET_BRANCH")
NEW_TAG="v${VERSION}.${GIT_HASH}"
echo "✅ New tag: $NEW_TAG"

# 3️⃣ Find existing tags with matching version
LOCAL_TAGS=$(git tag -l "v${VERSION}.*")
REMOTE_TAGS=$(git ls-remote --tags origin "v${VERSION}.*" | awk '{print $2}' | sed 's|refs/tags/||')

# 4️⃣ Delete existing tags
if [ -n "$LOCAL_TAGS" ] || [ -n "$REMOTE_TAGS" ]; then
    # Show existing tags
    [ -n "$LOCAL_TAGS" ] && echo "⚠️  Existing local tags:" && echo "$LOCAL_TAGS"
    [ -n "$REMOTE_TAGS" ] && echo "⚠️  Existing remote tags:" && echo "$REMOTE_TAGS"

    # Confirm deletion
    read -p "❗ Press Enter to confirm deletion of existing tags..."

    # Delete tags
    [ -n "$LOCAL_TAGS" ] && git tag -d $LOCAL_TAGS
    [ -n "$REMOTE_TAGS" ] && git push origin --delete $REMOTE_TAGS
    echo "✅ Deleted existing tags"
fi

# 5️⃣ Create and push new tag to remote only
git tag "$NEW_TAG" "$TARGET_BRANCH"
git push origin "$NEW_TAG"
git tag -d "$NEW_TAG" # delete local tag immediately

# 6️⃣ Show GitHub tag URL
REPO_URL=$(git config --get remote.origin.url)
if [[ "$REPO_URL" =~ ^git@github.com:(.*)\.git$ ]]; then
    REPO_URL="https://github.com/${BASH_REMATCH[1]}"
else
    REPO_URL="${REPO_URL%.git}"
fi

cat <<EOF
✅ Pushed new tag to GitHub:

    $REPO_URL/releases/tag/$NEW_TAG

EOF
