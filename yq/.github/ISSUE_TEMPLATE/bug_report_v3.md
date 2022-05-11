---
name: Bug report - V3
about: Create a report to help us improve
title: ''
labels: bug, v3
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

Note that any how to questions should be posted in the discussion board and not raised as an issue.

Version of yq: 3.X.X
Operating system: mac/linux/windows/....
Installed via: docker/binary release/homebrew/snap/...

**Input Yaml**
Concise yaml document(s) (as simple as possible to show the bug, please keep it to 10 lines or less)
data1.yml:
```yaml
this: should really work
```

data2.yml:
```yaml
but: it strangely didn't
```

**Command**
The command you ran:
```
yq merge data1.yml data2.yml
```

**Actual behavior**

```yaml
cat: meow
```

**Expected behavior**

```yaml
this: should really work
but: it strangely didn't
```

**Additional context**
Add any other context about the problem here.
