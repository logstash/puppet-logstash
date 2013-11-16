# == Define: logstash::output::boundary
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
# [*api_key*]
#   This output lets you send annotations to Boundary based on Logstash
#   events  Note that since Logstash maintains no state these will be
#   one-shot events  By default the start and stop time will be the event
#   timestamp  Your Boundary API key
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*auto*]
#   Auto If set to true, logstash will try to pull boundary fields out of
#   the event. Any field explicitly set by config options will override
#   these. ['type', 'subtype', 'creationtime', 'endtime', 'links', 'tags',
#   'loc']
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*bsubtype*]
#   Sub-Type
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*btags*]
#   Tags Set any custom tags for this event Default are the Logstash tags
#   if any
#   Value type is array
#   Default value: None
#   This variable is optional
#
# [*btype*]
#   Type
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*end_time*]
#   End time Override the stop time Note that Boundary requires this to be
#   seconds since epoch If overriding, it is your responsibility to type
#   this correctly By default this is set to event.unix_timestamp.to_i
#   Value type is string
#   Default value: None
#   This variable is optional
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
# [*org_id*]
#   Your Boundary Org ID
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*start_time*]
#   Start time Override the start time Note that Boundary requires this to
#   be seconds since epoch If overriding, it is your responsibility to
#   type this correctly By default this is set to
#   event.unix_timestamp.to_i
#   Value type is string
#   Default value: None
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
#  http://logstash.net/docs/1.2.2/outputs/boundary
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
define logstash::output::boundary (
  $api_key,
  $org_id,
  $exclude_tags = '',
  $btags        = '',
  $btype        = '',
  $end_time     = '',
  $bsubtype     = '',
  $fields       = '',
  $auto         = '',
  $start_time   = '',
  $tags         = '',
  $type         = '',
  $codec        = '',
  $conditional  = '',
  $instances    = [ 'agent' ]
) {

  require logstash::params

  File {
    owner => $logstash::logstash_user,
    group => $logstash::logstash_group
  }

  if $logstash::multi_instance == true {

    $confdirstart = prefix($instances, "${logstash::configdir}/")
    $conffiles    = suffix($confdirstart, "/config/output_boundary_${name}")
    $services     = prefix($instances, 'logstash-')
    $filesdir     = "${logstash::configdir}/files/output/boundary/${name}"

  } else {

    $conffiles = "${logstash::configdir}/conf.d/output_boundary_${name}"
    $services  = 'logstash'
    $filesdir  = "${logstash::configdir}/files/output/boundary/${name}"

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

  if ($tags != '') {
    validate_array($tags)
    $arr_tags = join($tags, '\', \'')
    $opt_tags = "${opt_indent}tags => ['${arr_tags}']\n"
  }

  if ($fields != '') {
    validate_array($fields)
    $arr_fields = join($fields, '\', \'')
    $opt_fields = "${opt_indent}fields => ['${arr_fields}']\n"
  }

  if ($btags != '') {
    validate_array($btags)
    $arr_btags = join($btags, '\', \'')
    $opt_btags = "${opt_indent}btags => ['${arr_btags}']\n"
  }

  if ($exclude_tags != '') {
    validate_array($exclude_tags)
    $arr_exclude_tags = join($exclude_tags, '\', \'')
    $opt_exclude_tags = "${opt_indent}exclude_tags => ['${arr_exclude_tags}']\n"
  }

  if ($auto != '') {
    validate_bool($auto)
    $opt_auto = "${opt_indent}auto => ${auto}\n"
  }

  if ($start_time != '') {
    validate_string($start_time)
    $opt_start_time = "${opt_indent}start_time => \"${start_time}\"\n"
  }

  if ($bsubtype != '') {
    validate_string($bsubtype)
    $opt_bsubtype = "${opt_indent}bsubtype => \"${bsubtype}\"\n"
  }

  if ($org_id != '') {
    validate_string($org_id)
    $opt_org_id = "${opt_indent}org_id => \"${org_id}\"\n"
  }

  if ($btype != '') {
    validate_string($btype)
    $opt_btype = "${opt_indent}btype => \"${btype}\"\n"
  }

  if ($end_time != '') {
    validate_string($end_time)
    $opt_end_time = "${opt_indent}end_time => \"${end_time}\"\n"
  }

  if ($type != '') {
    validate_string($type)
    $opt_type = "${opt_indent}type => \"${type}\"\n"
  }

  if ($api_key != '') {
    validate_string($api_key)
    $opt_api_key = "${opt_indent}api_key => \"${api_key}\"\n"
  }

  #### Write config file

  file { $conffiles:
    ensure  => present,
    content => "output {\n${opt_cond_start} boundary {\n${opt_api_key}${opt_auto}${opt_bsubtype}${opt_btags}${opt_btype}${opt_end_time}${opt_exclude_tags}${opt_fields}${opt_codec}${opt_org_id}${opt_start_time}${opt_tags}${opt_type}${opt_cond_end}}\n}\n",
    mode    => '0440',
    notify  => Service[$services],
    require => Class['logstash::package', 'logstash::config']
  }
}
