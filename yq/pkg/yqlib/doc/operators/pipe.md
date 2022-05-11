# Pipe

Pipe the results of an expression into another. Like the bash operator.

{% hint style="warning" %}
Note that versions prior to 4.18 require the 'eval/e' command to be specified.&#x20;

`yq e <exp> <file>`
{% endhint %}

## Simple Pipe
Given a sample.yml file of:
```yaml
a:
  b: cat
```
then
```bash
yq '.a | .b' sample.yml
```
will output
```yaml
cat
```

## Multiple updates
Given a sample.yml file of:
```yaml
a: cow
b: sheep
c: same
```
then
```bash
yq '.a = "cat" | .b = "dog"' sample.yml
```
will output
```yaml
a: cat
b: dog
c: same
```

