# Fluentd Plugin: Kubernetes Annotation Filter

Checks whether the container name is included in an annotation on the pod that is the source of a log entry.

## Operations

### Installation

Add the following to your Gemfile:

```ruby
gem 'fluent-plugin-kubernetes-annotations-filter
```

### Dependencies

This plugin relies on _Kubernetes metadata_ being available on log records. This metadata can be obtained by use of the
[kuberenetes_metadata_filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) plugin.

Specifically, this plugin relies on the following fields:

| Field                       | Content                                                        |
|-----------------------------|----------------------------------------------------------------|
| `kubernetes.container_name` | The name of the container the record was emitted from          |
| `kubernetes.annotations`    | The annotations applied to the pod the record was emitted from |

### Configuration

An example configuration could look like:

```
<filter camelid>
@type kubernetes_annotation

<contains_container_name>
annotation dromedary
</contains_container_name>
</filter>
```

This would look for the value of `kubernetes.container_name` in the `kubernetes.annotations.dromedary` field of records
tagged "camelid"; for example, these records would be allowed to pass through the filter:

```
{"message": "hi", "kubernetes": {"containter_name": "beluga", ..., "annotations": { "dromedary": "[\"beluga\"]" } } }
{"message": "wat", "kubernetes": {"containter_name": "humpback", ..., "annotations": { "dromedary": "[\"minke\", \"humpback\"]" } } }
```

but these ones would not:

```
{"message": "hi", "kubernetes": {"containter_name": "pelican", ..., "annotations": { "dromedary": "[\"minke\", \"humpback\"]" } } }
{"message": "wat", "kubernetes": {"containter_name": "gannet", ..., "annotations": { } } }
```

Note that the value of the provided annotation is expected to be a _JSON array_ inside a string (this appears to be the
way people suggest encoding data of this kind).

The `pass_through_events_without_kubernetes_tags` option can be used to control whether objects without Kubernetes tags
are passed through the filter or dropped. It defaults to `false`.

## Maintainers

delivery-engineers@redbubble.com


    Copyright (c) Redbubble. All rights reserved.
