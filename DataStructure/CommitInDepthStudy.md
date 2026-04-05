# 🧪 Git Plumbing Demo — Trees, Changes & Isolation

This demo shows how Git internally tracks changes using blobs, trees, and commits.

---

## 🎯 What You’ll Learn

* How nested folders are represented as trees
* How file changes affect only specific trees
* Why unrelated folders remain unchanged
* How commits are built using plumbing commands

---

## 📂 Scenario

We create this structure:

```
fol1/
  f1.txt
  f2.txt

fol2/
  f3.txt
```

Then:

* Modify only `fol1/f2.txt`
* Observe how:

    * `fol1` tree changes ✅
    * `fol2` tree stays same ✅

---

## 🧠 Key Concept

Git tracks **content, not folders**

```
f2.txt changes
   ↓
fol1 tree changes
   ↓
root tree changes

fol2 unchanged → tree unchanged
```

---

## ⚙️ How to Run

```bash
chmod +x plumbing_demo.sh
./plumbing_demo.sh
```

---

## 🔍 Expected Observations

* Same content → same hash
* Changed file → new blob → new tree
* Unchanged folder → identical tree hash

---

## 🧬 Mental Model

```
Blob (file content)
   ↓
Tree (directory)
   ↓
Commit (snapshot)
   ↓
Branch (pointer)
```

---

## 🏁 Final Takeaway

* Git trees are deterministic
* Any small change propagates upward
* Unrelated trees remain untouched
* You manually recreated Git internals

---
