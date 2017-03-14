# fluent-plugin-pagerduty does not work

Fluentd Output plugin to relay alert notification from application to [PagerDuty](http://www.pagerduty.com/).

## Installation

install with `gem` or `fluent-gem` command as:

```
# for fluentd
$ gem install fluent-plugin-pagerduty

# for td-agent
$ sudo /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-pagerduty -v 0.0.1

# for td-agent2
$ sudo td-agent-gem install fluent-plugin-pagerduty -v 0.0.1
```

## Usage

1. add service selecting `Service Type : Generic API system` on PagerDuty websites
2. copy API Key from the `Services` page.
3. install fluent-plugin-pagerduty with gem or fluent-gem command.
4. create fluentd configuration like below.
5. restart fluentd process.
6. send test message for fluent-plugin-pagerduty

#### configuration example

```
<source>
  type forward
</source>

<source>
  type http
  port 8888
</source>

<match notify.pagerduty>
  type pagerduty
  service_key ******************
</match>
```

#### notify example

```
# via forward
$ echo '{"description":"Form validation has failed","details":{"name":"success","mail":"failed"}}' | fluent-cat notify.pagerduty

# via http
$ curl http://localhost:8888/notify.pagerduty -F 'json={"description":"Form validation has failed","details":{"name":"success","mail":"failed"}}'
```

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

Apache License, Version 2.0

