# fluent-plugin-pagerduty

Fluentd Output plugin to trigger alert notification via [PagerDuty](http://www.pagerduty.com/).

## Installation

install with `gem` or `fluent-gem` command as:

```
$ gem install fluent-plugin-pagerduty
$ sudo fluent-gem install fluent-plugin-pagerduty
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
  type tcp
</source>

<match notify.pagerduty>
  type pagerduty
  service_key ******************
</match>
```

#### notify example

```
echo '{"description":"site went down!","details":{"web01":"up","db01":"down"}}' | fluent-cat notify.pagerduty
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

