class Fluent::PagerdutyOutput < Fluent::Output
  Fluent::Plugin.register_output('pagerduty', self)

  def initialize
    require 'pagerduty'
    super
  end

  config_param :service_key, :string, :default => nil
  config_param :event_type, :string, :default => 'trigger'
  config_param :description, :string, :default => nil
  config_param :incident_key, :string, :default => nil

  def configure(conf)
    super

    # API requires service key
    if @service_key.nil?
      $log.warn "pagerduty: service_key required."
    end

    # PagerDuty trigger event type requires description, other event types do not
    if @event_type == 'trigger' && @description.nil?
      $log.warn "pagerduty: description required for trigger event_type."
    end
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      call_pagerduty(tag, record)
    end

    chain.next
  end

  def call_pagerduty(tag, record)
    begin
      expander = PlaceholderExpander.new({:log => log})
      tag_parts = tag.split('.')
      placeholder_values = {
        'tag'       => tag,
        'tag_parts' => tag_parts,
        'record'    => record,
      }

      placeholders = expander.prepare_placeholders(placeholder_values)
      
      service_key = record['service_key'] || @service_key
      event_type = record['event_type'] || @event_type
      description = record['description'] || record['message'] || @description
      incident_key = record['incident_key'] || @incident_key
      details = record['details'] || record
      options = {"details" => details}
      
      description = expander.expand(description, placeholders)
      
      if !@incident_key.nil?
        incident_key = expander.expand(incident_key, placeholders)
        api = PagerdutyIncident.new(service_key, incident_key)
      else
        api = Pagerduty.new(service_key)
      end

      incident = api.trigger description, options
    rescue => e
      $log.error "pagerduty: request failed. ", :error_class=>e.class, :error=>e.message
    end
  end
end


# Modified PlaceholderExpander borrowed from fluent-plugin-record-reformer
# https://github.com/sonots/fluent-plugin-record-reformer
# Original author: Naotoshi Seo
# MIT License: https://github.com/sonots/fluent-plugin-record-reformer/blob/master/LICENSE
# Modifications: Michael Karlesky
# Changes:
#  - Stripped down to limited use case
#  - Building of placeholders is now recursive to handle any depth of hash, array, and primitive
class PlaceholderExpander
  attr_reader :placeholders, :log

  def initialize(params)
    @log = params[:log]
  end

  def prepare_placeholders(placeholder_values)
    placeholders = {}

    placeholder_values.each do |key, value|
      # For any entry in `placeholder_values` that is a hash, we effectively ignore its internal name.
      # For example, `record` is an important hash, but referencing it at the top-level is superfluous namespacing.
      # Instead of '${record["Node"]["Location"]}',
      #  '${Node["Location"]}' more closely maps to a user's knowledge of a data to be processed.
      if value.kind_of?(Hash)
        value.each do |key, value|
          build_placeholders(placeholders, key, value)
        end
      else
        build_placeholders(placeholders, key, value)        
      end
    end

    placeholders
  end

  # Expand string (`${foo["bar"]}`) with placeholders
  def expand(str, placeholders)
    single_placeholder_matched = str.match(/\A(\${[^}]+}|__[A-Z_]+__)\z/)
    if single_placeholder_matched
      log_if_unknown_placeholder($1, placeholders)
      return placeholders[single_placeholder_matched[1]]
    end
    str.gsub(/(\${[^}]+}|__[A-Z_]+__)/) {
      log_if_unknown_placeholder($1, placeholders)
      placeholders[$1]
    }
  end

  private

  # Recurses to build any depth of hash, arrays, and primitives
  def build_placeholders(placeholders, key, value)
    if value.kind_of?(Array) # tag_parts, etc
      size = value.size
      value.each_with_index do |v, idx|
        build_placeholders(placeholders, "#{key}[#{idx}]", v)
        build_placeholders(placeholders, "#{key}[#{idx-size}]", v) # support [-1]
      end
    elsif value.kind_of?(Hash) # record, etc
      value.each do |k, v|
        build_placeholders(placeholders, %Q[#{key}["#{k}"]], v) # record["foo"]
      end
    else
      placeholders.store("${#{key}}", value)
    end
  end

  def log_if_unknown_placeholder(placeholder, placeholders)
    unless placeholders.include?(placeholder)
      log.warn "pagerduty: unknown placeholder `#{placeholder}` found"
    end
  end
end

