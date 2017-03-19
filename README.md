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

#### configuration example

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

