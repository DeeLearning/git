#!/usr/bin/env bash

# --- OS Detection & Shell Switcher ---
if [[ "$OSTYPE" == "darwin"* ]]; then
  # If on Mac and NOT already running in zsh, re-run with zsh
  if [ -z "$ZSH_VERSION" ]; then
    exec zsh "$0" "$@"
  fi
else
  # If on Linux (Ubuntu) and NOT already running in bash, re-run with bash
  if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
  fi
fi

# --- Start of Logic ---
echo "Running on: $(uname) with shell: $0"
echo "🚀 Starting Git Plumbing Demo (Maintaining History)..."
echo ""

rm -rf git-plumbing-demo
mkdir git-plumbing-demo
cd git-plumbing-demo

git init -q
git config user.name "Demo"
git config user.email "demo@example.com"

echo ""
echo "========================================"
echo "📂 STEP 1: Create Nested Structure"
echo "========================================"

mkdir -p fol1 fol2

echo "File 1 content" > fol1/f1.txt
echo "File 2 content" > fol1/f2.txt
echo "Another file" > fol2/f3.txt

echo "📁 Structure:"
ls -R

echo ""
echo "========================================"
echo "🧱 STEP 2: Create BLOBS"
echo "========================================"

BLOB_F1=$(git hash-object -w fol1/f1.txt)
BLOB_F2=$(git hash-object -w fol1/f2.txt)
BLOB_F3=$(git hash-object -w fol2/f3.txt)

echo "📄 fol1/f1.txt → $BLOB_F1"
echo "📄 fol1/f2.txt → $BLOB_F2"
echo "📄 fol2/f3.txt → $BLOB_F3"

echo ""
echo "========================================"
echo "🌲 STEP 3: Build TREE for fol1"
echo "========================================"

git update-index --add --cacheinfo 100644 "$BLOB_F1" fol1/f1.txt
git update-index --add --cacheinfo 100644 "$BLOB_F2" fol1/f2.txt

TREE_FOL1=$(git write-tree)

echo "🌳 fol1 tree → $TREE_FOL1"
git ls-tree -r "$TREE_FOL1"

echo ""
echo "========================================"
echo "🌲 STEP 4: Build TREE for fol2"
echo "========================================"

git read-tree --empty

git update-index --add --cacheinfo 100644 "$BLOB_F3" fol2/f3.txt

TREE_FOL2=$(git write-tree)

echo "🌳 fol2 tree → $TREE_FOL2"
git ls-tree -r "$TREE_FOL2"

echo ""
echo "========================================"
echo "🌐 STEP 5: Combine into ROOT TREE"
echo "========================================"

git read-tree --empty

git update-index --add --cacheinfo 040000 "$TREE_FOL1" fol1
git update-index --add --cacheinfo 040000 "$TREE_FOL2" fol2

ROOT_TREE=$(git write-tree)

echo "🌍 Root tree → $ROOT_TREE"
git ls-tree "$ROOT_TREE"

echo ""
echo "========================================"
echo "🛠️ STEP 6: Create FIRST COMMIT"
echo "========================================"

COMMIT1=$(echo "Initial commit 🌱" | git commit-tree "$ROOT_TREE")

if [ -z "$COMMIT1" ]; then
  echo "❌ ERROR: COMMIT1 creation failed!"
  exit 1
fi

git update-ref refs/heads/main "$COMMIT1"

echo "✅ Commit1 → $COMMIT1"

echo ""
echo "========================================"
echo "✏️ STEP 7: Modify ONLY fol1/f2.txt"
echo "========================================"

echo "File 2 content UPDATED 🚀" > fol1/f2.txt
NEW_BLOB_F2=$(git hash-object -w fol1/f2.txt)

echo "🔁 New blob → $NEW_BLOB_F2"

echo ""
echo "========================================"
echo "🌲 STEP 8: Rebuild fol1 TREE"
echo "========================================"

git read-tree --empty

git update-index --add --cacheinfo 100644 "$BLOB_F1" fol1/f1.txt
git update-index --add --cacheinfo 100644 "$NEW_BLOB_F2" fol1/f2.txt

NEW_TREE_FOL1=$(git write-tree)

echo "🌳 OLD fol1 → $TREE_FOL1"
echo "🌳 NEW fol1 → $NEW_TREE_FOL1"

echo ""
echo "========================================"
echo "🌲 STEP 9: fol2 TREE (unchanged)"
echo "========================================"

echo "🌳 fol2 → $TREE_FOL2"

echo ""
echo "========================================"
echo "🌐 STEP 10: Rebuild ROOT TREE"
echo "========================================"

git read-tree --empty

git update-index --add --cacheinfo 040000 "$NEW_TREE_FOL1" fol1
git update-index --add --cacheinfo 040000 "$TREE_FOL2" fol2

NEW_ROOT_TREE=$(git write-tree)

echo "🌍 OLD root → $ROOT_TREE"
echo "🌍 NEW root → $NEW_ROOT_TREE"

echo ""
echo "========================================"
echo "🛡️ STEP 11: Create SECOND COMMIT"
echo "========================================"

if [ -z "$COMMIT1" ]; then
  echo "❌ ERROR: COMMIT1 is empty before creating COMMIT2!"
  exit 1
fi

COMMIT2=$(echo "Updated f2 ✨" | git commit-tree "$NEW_ROOT_TREE" -p "$COMMIT1")

if [ -z "$COMMIT2" ]; then
  echo "❌ ERROR: COMMIT2 creation failed!"
  exit 1
fi

git update-ref refs/heads/main "$COMMIT2"

echo "✅ Commit2 → $COMMIT2"

echo ""
echo "========================================"
echo "🔍 STEP 12: VERIFY HISTORY"
echo "========================================"

echo "📜 git log:"
git log --oneline --graph

echo ""
echo "🧭 reflog (shows full movement):"
git reflog

echo ""
echo "🧩 dangling commits (if any):"
git fsck --lost-found || true

echo ""
echo "========================================"
echo "🎯 FINAL OBSERVATIONS"
echo "========================================"

echo "✔ fol1 change → new blob → new tree"
echo "✔ fol2 tree unchanged"
echo "✔ root tree updated due to fol1"
echo "✔ history preserved via parent link"
echo "✔ unreachable commits (if any) still exist internally"

echo ""
echo "🏁 Demo Complete 🎉"
