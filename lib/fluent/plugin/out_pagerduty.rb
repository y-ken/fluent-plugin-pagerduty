class Fluent::PagerdutyOutput < Fluent::Output
  Fluent::Plugin.register_output('pagerduty', self)

  def initialize
    require 'pagerduty'
    super
  end

  config_param :service_key, :string, :default => nil
  config_param :event_type, :string, :default => 'trigger'
  config_param :description, :string, :default => nil

  def configure(conf)
    super

    if @service_key.nil?
      $log.warn "pagerduty: service_key required."
    end
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      call_pagerduty(record)
    end

    chain.next
  end

  def call_pagerduty(record)
    begin
      service_key = record['service_key'] || @service_key
      event_type = record['event_type'] || @event_type
      description = record['description'] || record['message'] || @description
      details = record['details'] || record
      options = {"details" => details}
      api = Pagerduty.new(service_key)
      incident = api.trigger description, options
    rescue => e
      $log.error "pagerduty: request failed. ", :error_class=>e.class, :error=>e.message
    end
  end
end
