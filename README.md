# Fluentd Plugin: Kubernetes Annotation Filter

Checks whether the container name is included in an annotation on the pod that is the source of a log entry.

## Development

### Running Locally

It can be a bit of a challenge to get fluentd running locally for "poke-it-and-see" style testing. One approach is to:

1. Get a docker container with fluentd in it
1. Create an `app/plugins` directory
1. Copy `lib/fluent/plugin/*` from this repository into that directory
1. Create a fluentd configuration that uses this plugin, taking input from a file in the `/app` directory. An example
   configuration can be found at [example/fluentd-test.conf](example/fluentd-test.conf).
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
gem 'fluent-plugin-annotation-filter'
```

### Dependencies

This plugin relies on _Kubernetes metadata_ being available on log records. This metadata is provided by the
[Kubernetes_metadata_filter](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter) plugin.

Specifically, we rely on the following fields:

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
{"message": "hi", "kubernetes": {"container_name": "beluga", ..., "annotations": { "dromedary": "[\"beluga\"]" } } }
{"message": "wat", "kubernetes": {"container_name": "humpback", ..., "annotations": { "dromedary": "[\"minke\", \"humpback\"]" } } }
```

but these ones would not:

```
{"message": "hi", "kubernetes": {"container_name": "pelican", ..., "annotations": { "dromedary": "[\"minke\", \"humpback\"]" } } }
{"message": "wat", "kubernetes": {"container_name": "gannet", ..., "annotations": { } } }
```

Note that the value of the provided annotation is expected to be a _JSON array_ inside a string (this appears to be the
way people suggest encoding data of this kind).

The `pass_through_events_without_kubernetes_tags` option can be used to control whether objects without Kubernetes tags
are passed through the filter or dropped. It defaults to `false`, i.e. drop unmatched objects.

## Maintainers

delivery-engineers@redbubble.com

    fluentd-plugin-annotation-filter

    Copyright (c) Redbubble

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

