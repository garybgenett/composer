# Reduce

Reduce is a powerful way to process a collection of data into a new form.

```
<exp> as $<name> ireduce (<init>; <block>)
```

e.g.

```
.[] as $item ireduce (0; . + $item)
```

On the LHS we are configuring the collection of items that will be reduced `<exp>` as well as what each element will be called `$<name>`. Note that the array has been splatted into its individual elements.

On the RHS there is `<init>`, the starting value of the accumulator and `<block>`, the expression that will update the accumulator for each element in the collection. Note that within the block expression, `.` will evaluate to the current value of the accumulator. 

## yq vs jq syntax
Reduce syntax in `yq` is a little different from `jq` - as `yq` (currently) isn't as sophisticated as `jq` and its only supports infix notation (e.g. a + b, where the operator is in the middle of the two parameters) - where as `jq` uses a mix of infix notation with _prefix_ notation (e.g. `reduce a b` is like writing `+ a b`).

To that end, the reduce operator is called `ireduce` for backwards compatability if a `jq` like prefix version of `reduce` is ever added.

{% hint style="warning" %}
Note that versions prior to 4.18 require the 'eval/e' command to be specified.&#x20;

`yq e <exp> <file>`
{% endhint %}

## Sum numbers
Given a sample.yml file of:
```yaml
- 10
- 2
- 5
- 3
```
then
```bash
yq '.[] as $item ireduce (0; . + $item)' sample.yml
```
will output
```yaml
20
```

## Merge all yaml files together
Given a sample.yml file of:
```yaml
a: cat
```
And another sample another.yml file of:
```yaml
b: dog
```
then
```bash
yq eval-all '. as $item ireduce ({}; . * $item )' sample.yml another.yml
```
will output
```yaml
a: cat
b: dog
```

## Convert an array to an object
Given a sample.yml file of:
```yaml
- name: Cathy
  has: apples
- name: Bob
  has: bananas
```
then
```bash
yq '.[] as $item ireduce ({}; .[$item | .name] = ($item | .has) )' sample.yml
```
will output
```yaml
Cathy: apples
Bob: bananas
```

