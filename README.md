# fluent-plugin-pagerduty

Fluentd Output plugin to relay alert notification from application to [PagerDuty](http://www.pagerduty.com/).

## Installation

install with `td-agnet-gem` or `fluent-gem`, `gem` command as:

```
# for td-agent2 (recommend)
$ sudo td-agent-gem install fluent-plugin-pagerduty -v 0.0.1

# for td-agent
$ sudo /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-pagerduty -v 0.0.1

# for system installed fluentd
$ gem install fluent-plugin-pagerduty
```

## Usage

<img width="1025" alt="screenshot 2017-03-18 18 20 43" src="https://cloud.githubusercontent.com/assets/1428486/24077350/ab9f9dd4-0c07-11e7-9f9f-8cd27a451b6e.png">

1. add service selecting `Service Type : Generic API system` on PagerDuty websites
2. copy API Key from the `Services` page.
3. install fluent-plugin-pagerduty with gem or fluent-gem command.
4. create fluentd configuration like below.
5. restart fluentd process.
6. send test message for fluent-plugin-pagerduty

### Examples

#### Simple alert (JSON pass-thru)

In this example, a JSON record already conforming to the PagerDuty API is processed by Fluentd and passed through to PagerDuty as-is, triggering a simple alert.

```
<source>
  @type forward
</source>

<source>
  @type http
  port 8888
</source>

<match notify.pagerduty>
  type pagerduty
  service_key ******************
</match>
```

```
# via forward
$ echo '{"description":"Form validation has failed","details":{"name":"success","mail":"failed"}}' | fluent-cat notify.pagerduty

# via http
$ curl http://localhost:8888/notify.pagerduty -F 'json={"description":"Form validation has failed","details":{"name":"success","mail":"failed"}}'
```

#### Advanced alert (transformed JSON)

In this example, a JSON record is referenced to build a PagerDuty event with an incident key for managing [de-duplication](https://v2.developer.pagerduty.com/docs/events-api#incident-de-duplication-and-incident_key).

```
<source>
  @type forward
</source>

<source>
  @type http
  port 8888
</source>

<match notify.pagerduty>
  type pagerduty
  service_key   ******************
  description   Alarm@${Node["Location"]}:: ${Log["Message"]}
  incident_key  [${tag_parts[-1]}] ${Log["File"]}:${Log["Line"]}
</match>
```

```
# via forward
$ echo '{"Node":{"Location":"Somewhere","IP Address":"10.0.0.1"},"Log":{"Level": "ERROR","File":"FooBar.cpp","Line":42,"Message":"A very important logging message"}}' | fluent-cat notify.pagerduty

# via http
$ curl http://localhost:8888/notify.pagerduty -F 'json={"Node":{"Location":"Somewhere","IP Address":"10.0.0.1"},"Log":{"Level": "ERROR","File":"FooBar.cpp","Line":42,"Message":"A very important logging message"}}'
```


### Option Parameters

- `service_key` (required)

    The unique API identifier generated for each PagerDuty service belonging to a PagerDuty account. Must be present for any PagerDuty events.

- `event_type` (optional)

    The PagerDuty event type: `trigger`, `acknowledge`, or `resolve`. If unspecified, the default is `trigger`.

- `description` (conditionally required)

    The message content of a PagerDuty event. PagerDuty event types of `trigger` must contain a description. The content of the description may be built using Placeholders (see next section).

- `incident_key` (optional)

    The identifier used for PagerDuty's [de-duplication of events](https://v2.developer.pagerduty.com/docs/events-api#incident-de-duplication-and-incident_key). The content of the incident key may be built using Placeholders (see next section).

### Placeholders

These placeholders are available:

* ${…}
  * `hashName["key"]` Value of `key` in named hash
  * `arrayName[N]` Value at index _N_ in named array
  * `primitive` Value of named primitive
  
    Placeholders are built recursively and concatenated. For example, a specific value within a hash containing an array of hashes could be referenced as: `${foo["bar"][2]["baz"]}`.
* ${tag} Input tag
* ${tag\_parts[N]} Input tag splitted by '.' indexed with _N_ such as `${tag_parts[0]}`, `${tag_parts[-1]}`. 

Placeholder functionality is derived from features of [fluent-plugin-record-reformer](https://github.com/sonots/fluent-plugin-record-reformer).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

patches welcome!

## Copyright

Copyright (c) 2013- Kentaro Yoshida (@yoshi_ken)

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

