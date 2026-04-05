# 🧠 Git Internals + ⚙️ Plumbing Masterclass

> Git is a **content-addressable database** where everything is stored as immutable objects.
> This guide walks from **core concepts → actual low-level commands**.

---

# 🧱 PART 1 — Core Git Objects (Deep Understanding)

All objects live inside:

```
.git/objects/
```

Each object is:

* Compressed
* Identified by SHA-1 hash
* Immutable (never changes once created)

---

## 📦 1. Blob — File Content Only

👉 A **Blob** stores raw file data.

**Does NOT include:**

* Filename
* Directory
* Metadata

**Example**

```bash
echo "Hello World" | git hash-object -w --stdin
```

Output:

```
e965047ad7c57865823c7d992b1d046ea66edf78
```

Now check storage:

```
.git/objects/e9/65047ad7c57865823c7d992b1d046ea66edf78
```

### 🔬 Internals

Git stores:

```
blob 12\0Hello World
```

Then hashes it → produces the ID.

💡 Same content anywhere → same blob hash

---

## 🌲 2. Tree — Directory Structure

👉 A **Tree** maps names → blobs or subtrees

Think:

```
README.md → blob
src/      → tree
```

### Example (Inspect existing tree)

```bash
git ls-tree HEAD
```

Output:

```
100644 blob a1b2c3...    README.md
040000 tree d4e5f6...    src
```

### Key Details

* `100644` → normal file
* `100755` → executable
* `040000` → directory (tree)

💡 A folder is just a **reference to another tree**

---

## 📸 3. Commit — Snapshot + History

👉 A **Commit** points to:

* A tree (current project state)
* A parent commit (history)

### Example Commit Content

```
tree a1b2c3...
parent d4e5f6...
author Deepak <email> 1710000000 +0530
committer Deepak <email> 1710000000 +0530

Initial commit
```

### Create manually

```bash
echo "My commit" | git commit-tree <TREE_HASH>
```

---

## 🏷️ 4. Tag — Named Reference

👉 A **Tag** points to a commit.

### Annotated Tag Example

```
object <commit_hash>
type commit
tag v1.0
tagger Deepak <email> 1710000000 +0530
```

### Key Difference

* Lightweight → simple pointer
* Annotated → full object in database

---

## 🔗 Object Relationship

```
Tag → Commit → Tree → Blob
             ↓
          Parent Commit
```

---

# ⚙️ PART 2 — Manual Plumbing Workflow

We now recreate Git operations manually.

---

# 📂 Case 1 — Create a Blob

### 🎯 Goal

Store raw content in Git.

```bash
MY_BLOB=$(echo "Hello Git Internals" | git hash-object -w --stdin)
echo "Blob: $MY_BLOB"
```

### 🔍 Verify

```bash
git cat-file -p $MY_BLOB
```

Output:

```
Hello Git Internals
```

---

# 🌲 Case 2 — Build a Tree

### 🎯 Goal

Create a directory structure manually.

```bash
# Create blobs
HASH_ROOT=$(echo "Root file content" | git hash-object -w --stdin)
HASH_SUB=$(echo "Inside src folder" | git hash-object -w --stdin)

# Stage manually
git update-index --add --cacheinfo 100644 $HASH_ROOT README.md
git update-index --add --cacheinfo 100644 $HASH_SUB src/main.py

# Write tree
RESULT_TREE=$(git write-tree)

echo "Tree: $RESULT_TREE"
```

### 🔍 Inspect Tree

```bash
git ls-tree -r $RESULT_TREE
```

Example output:

```
100644 blob <hash> README.md
100644 blob <hash> src/main.py
```

---

# 🛡️ Case 3 — Create a Commit Safely

### 🎯 Goal

Create a commit with validation and logging.

```bash
NEW_COMMIT=$( {
  echo "Logging side action..." > plumbing.log
  echo "Initial plumbing commit" | git commit-tree $RESULT_TREE
} 2>> plumbing.log )

if [ $? -ne 0 ] || [ -z "$NEW_COMMIT" ]; then
    echo "ERROR: Plumbing failed. Check plumbing.log"
    exit 1
fi

git update-ref refs/heads/main $NEW_COMMIT

echo "Commit: $NEW_COMMIT"
```

---

# 🔍 Additional Example — Add Parent Commit

If you want history:

```bash
PARENT=$(git rev-parse HEAD)

NEW_COMMIT=$(echo "Next commit" | git commit-tree $RESULT_TREE -p $PARENT)
```

---

# 🔍 Useful Debug Commands

### Inspect object type

```bash
git cat-file -t <hash>
```

### Inspect object content

```bash
git cat-file -p <hash>
```

### View commit history

```bash
git log --oneline
```

---

# 🧰 Symbol Cheat Sheet

| Symbol | Meaning        |                     |
| ------ | -------------- | ------------------- |
| `      | `              | Pipe output → input |
| `$( )` | Capture output |                     |
| `{ }`  | Group commands |                     |
| `2>>`  | Append errors  |                     |
| `$?`   | Exit status    |                     |

---

# 🧩 End-to-End Flow

```
Content
  ↓
Blob (git hash-object)
  ↓
Index (git update-index)
  ↓
Tree (git write-tree)
  ↓
Commit (git commit-tree)
  ↓
Branch (git update-ref)
```

---

# 🏁 Final Insight

Standard Git commands:

```bash
git add .
git commit -m "message"
```

Internally perform:

1. Create blobs
2. Build tree
3. Create commit
4. Move branch reference

Understanding this flow helps with:

* Debugging corrupted repos
* Building custom tooling
* Understanding Git performance and storage

---

📎 Source reference:


---
