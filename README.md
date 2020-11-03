# Fluentd Plugin: Kubernetes Annotation Filter

Checks whether the container name is included in an annotation on the pod that is the source of a log entry.

## Development

### Running Locally

It can be a bit of a challenge to get fluentd running locally for "poke-it-and-see" style testing. One approach is to:

1. Pull the Redbubble [fluentd container](https://hub.docker.com/repository/docker/redbubble/debian-fluentd)
1. Create an `app/plugins` directory
1. Copy `lib/fluent/plugin/*` from this repository into that directory
1. Create a fluentd configuration that uses this plugin, taking input from a file in the `/app` directory. An example
   configuration can be found at [example/fluentd-test.conf].
1. Run the container
1. Put your test lines into the file
1. Watch the output

This is not a particularly nice way to develop anything, but it does _work_. You'll then need to copy the modified
source code _back_ into this repository.

### Tests

You can run tests locally with:

```
> rspec
```

Or in docker with:

```
> make test
```

The tests are written using Fluent's [Test Driver](https://docs.fluentd.org/plugin-development/plugin-test-code); this
requires the `test-unit` gem be included (for some helper methods we're not using) in addition to `rspec`, which is
actually used to run the tests (in accordance with what all the rest of DRE's Ruby code uses).

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
