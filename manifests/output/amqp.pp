# == Define: logstash::output::amqp
#
#
#
# === Parameters
#
# [*codec*]
#   A codec value.  It is recommended that you use the logstash_codec function
#   to derive this variable. Example: logstash_codec('graphite', {'charset' => 'UTF-8'})
#   but you could just pass a string, Example: "graphite{ charset => 'UTF-8' }"
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*conditional*]
#   Surrounds the rule with a conditional.  It is recommended that you use the
#   logstash_conditional function, Example: logstash_conditional('[type] == "apache"')
#   or, Example: logstash_conditional(['[loglevel] == "ERROR"','[deployment] == "production"'], 'or')
#   but you could just pass a string, Example: '[loglevel] == "ERROR" or [deployment] == "production"'
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*debug*]
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*durable*]
#   Value type is boolean
#   Default value: true
#   This variable is optional
#
# [*exchange*]
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*exchange_type*]
#   Value can be any of: "fanout", "direct", "topic"
#   Default value: None
#   This variable is required
#
# [*exclude_tags*]
#   Only handle events without any of these tags. Note this check is
#   additional to type and tags.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*fields*]
#   Only handle events with all of these fields. Optional.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*host*]
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*key*]
#   Value type is string
#   Default value: "logstash"
#   This variable is optional
#
# [*password*]
#   Value type is password
#   Default value: "guest"
#   This variable is optional
#
# [*persistent*]
#   Value type is boolean
#   Default value: true
#   This variable is optional
#
# [*port*]
#   Value type is number
#   Default value: 5672
#   This variable is optional
#
# [*ssl*]
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*tags*]
#   Only handle events with all of these tags.  Note that if you specify a
#   type, the event must also match that type. Optional.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*type*]
#   The type to act on. If a type is given, then this output will only act
#   on messages with the same type. See any input plugin's "type"
#   attribute for more. Optional.
#   Value type is string
#   Default value: ""
#   This variable is optional
#
# [*user*]
#   Value type is string
#   Default value: "guest"
#   This variable is optional
#
# [*verify_ssl*]
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*vhost*]
#   Value type is string
#   Default value: "/"
#   This variable is optional
#
# [*instances*]
#   Array of instance names to which this define is.
#   Value type is array
#   Default value: [ 'array' ]
#   This variable is optional
#
# === Extra information
#
#  This define is created based on LogStash version 1.2.2
#  Extra information about this output can be found at:
#  http://logstash.net/docs/1.2.2/outputs/amqp
#
#  Need help? http://logstash.net/docs/1.2.2/learn
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
# === Contributors
#
# * Luke Chavers <mailto:vmadman@gmail.com> - Added Initial Logstash 1.2.x Support
#
define logstash::output::amqp (
  $exchange_type,
  $host,
  $password      = '',
  $debug         = '',
  $exclude_tags  = '',
  $fields        = '',
  $durable       = '',
  $key           = '',
  $exchange      = '',
  $persistent    = '',
  $port          = '',
  $ssl           = '',
  $tags          = '',
  $type          = '',
  $user          = '',
  $verify_ssl    = '',
  $vhost         = '',
  $codec         = '',
  $conditional   = '',
  $instances     = [ 'agent' ]
) {

  require logstash::params

  File {
    owner => $logstash::logstash_user,
    group => $logstash::logstash_group
  }

  if $logstash::multi_instance == true {

    $confdirstart = prefix($instances, "${logstash::configdir}/")
    $conffiles    = suffix($confdirstart, "/config/output_amqp_${name}")
    $services     = prefix($instances, 'logstash-')
    $filesdir     = "${logstash::configdir}/files/output/amqp/${name}"

  } else {

    $conffiles = "${logstash::configdir}/conf.d/output_amqp_${name}"
    $services  = 'logstash'
    $filesdir  = "${logstash::configdir}/files/output/amqp/${name}"

  }

  #### Validate parameters

  if ($conditional != '') {
    validate_string($conditional)
    $opt_indent = "   "
    $opt_cond_start = " ${conditional}\n "
    $opt_cond_end = "  }\n "
  } else {
    $opt_indent = "  "
    $opt_cond_end = " "
  }

  if ($codec != '') {
    validate_string($codec)
    $opt_codec = "${opt_indent}codec => ${codec}\n"
  }



  validate_array($instances)

  if ($fields != '') {
    validate_array($fields)
    $arr_fields = join($fields, '\', \'')
    $opt_fields = "${opt_indent}fields => ['${arr_fields}']\n"
  }

  if ($tags != '') {
    validate_array($tags)
    $arr_tags = join($tags, '\', \'')
    $opt_tags = "${opt_indent}tags => ['${arr_tags}']\n"
  }

  if ($exclude_tags != '') {
    validate_array($exclude_tags)
    $arr_exclude_tags = join($exclude_tags, '\', \'')
    $opt_exclude_tags = "${opt_indent}exclude_tags => ['${arr_exclude_tags}']\n"
  }

  if ($verify_ssl != '') {
    validate_bool($verify_ssl)
    $opt_verify_ssl = "${opt_indent}verify_ssl => ${verify_ssl}\n"
  }

  if ($durable != '') {
    validate_bool($durable)
    $opt_durable = "${opt_indent}durable => ${durable}\n"
  }

  if ($ssl != '') {
    validate_bool($ssl)
    $opt_ssl = "${opt_indent}ssl => ${ssl}\n"
  }

  if ($persistent != '') {
    validate_bool($persistent)
    $opt_persistent = "${opt_indent}persistent => ${persistent}\n"
  }

  if ($debug != '') {
    validate_bool($debug)
    $opt_debug = "${opt_indent}debug => ${debug}\n"
  }

  if ($port != '') {
    if ! is_numeric($port) {
      fail("\"${port}\" is not a valid port parameter value")
    } else {
      $opt_port = "${opt_indent}port => ${port}\n"
    }
  }

  if ($exchange_type != '') {
    if ! ($exchange_type in ['fanout', 'direct', 'topic']) {
      fail("\"${exchange_type}\" is not a valid exchange_type parameter value")
    } else {
      $opt_exchange_type = "${opt_indent}exchange_type => \"${exchange_type}\"\n"
    }
  }

  if ($password != '') {
    validate_string($password)
    $opt_password = "${opt_indent}password => \"${password}\"\n"
  }

  if ($type != '') {
    validate_string($type)
    $opt_type = "${opt_indent}type => \"${type}\"\n"
  }

  if ($key != '') {
    validate_string($key)
    $opt_key = "${opt_indent}key => \"${key}\"\n"
  }

  if ($host != '') {
    validate_string($host)
    $opt_host = "${opt_indent}host => \"${host}\"\n"
  }

  if ($user != '') {
    validate_string($user)
    $opt_user = "${opt_indent}user => \"${user}\"\n"
  }

  if ($exchange != '') {
    validate_string($exchange)
    $opt_exchange = "${opt_indent}exchange => \"${exchange}\"\n"
  }

  if ($vhost != '') {
    validate_string($vhost)
    $opt_vhost = "${opt_indent}vhost => \"${vhost}\"\n"
  }

  #### Write config file

  file { $conffiles:
    ensure  => present,
    content => "output {\n${opt_cond_start} amqp {\n${opt_debug}${opt_durable}${opt_exchange}${opt_exchange_type}${opt_exclude_tags}${opt_fields}${opt_codec}${opt_host}${opt_key}${opt_password}${opt_persistent}${opt_port}${opt_ssl}${opt_tags}${opt_type}${opt_user}${opt_verify_ssl}${opt_vhost}${opt_cond_end}}\n}\n",
    mode    => '0440',
    notify  => Service[$services],
    require => Class['logstash::package', 'logstash::config']
  }
}
