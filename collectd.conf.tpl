Hostname "{{ HOST_NAME }}"

FQDNLookup false
Interval {{ COLLECT_INTERVAL | default("10") }}
Timeout 2
ReadThreads 5

LoadPlugin cpu
LoadPlugin df
LoadPlugin load
LoadPlugin memory
LoadPlugin disk
LoadPlugin interface
LoadPlugin uptime
LoadPlugin swap
LoadPlugin write_graphite
LoadPlugin processes
LoadPlugin disk

<Plugin processes>
  Process java
</Plugin>

<Plugin cpu>
  ReportByCpu {{ REPORT_BY_CPU | default("false") }}
</Plugin>

<Plugin df>
  # expose host's mounts into container using -v /:/host:ro  (location inside container does not matter much)
  # ignore rootfs; else, the root file-system would appear twice, causing
  # one of the updates to fail and spam the log
  FSType rootfs
  # ignore the usual virtual / temporary file-systems
  FSType sysfs
  FSType proc
  FSType devtmpfs
  FSType devpts
  FSType tmpfs
  FSType fusectl
  FSType cgroup
  FSType overlay
  FSType debugfs
  FSType pstore
  FSType securityfs
  FSType hugetlbfs
  FSType squashfs
  FSType mqueue
  MountPoint "/etc/resolv.conf"
  MountPoint "/etc/hostname"
  MountPoint "/etc/hosts"
  IgnoreSelected true
  ReportByDevice false
  ReportReserved true
  ReportInodes true
</Plugin>

<Plugin "disk">
  Disk "/^[hs]d[a-z]/"
  IgnoreSelected false
</Plugin>


<Plugin interface>
  Interface "lo"
  Interface "/^veth.*/"
  Interface "/^docker.*/"
  IgnoreSelected true
</Plugin>


<Plugin "write_graphite">
 <Carbon>
   Host "{{ GRAPHITE_HOST }}"
   Port "{{ GRAPHITE_PORT | default("2003") }}"
   Prefix "{{ GRAPHITE_PREFIX | default("collectd.") }}"
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates true
   AlwaysAppendDS false
 </Carbon>
</Plugin>

LoadPlugin aggregation

<Plugin "aggregation">
  <Aggregation>
    Plugin "cpu"
    Type "cpu"
    
    GroupBy "Host"
    GroupBy "TypeInstance"
    
    CalculateAverage true
  </Aggregation>
</Plugin>

LoadPlugin "match_regex" # we want to use this for our Matching
<Chain "PostCache">
  <Rule> # Send "cpu" values to the aggregation plugin.
    <Match regex>
      Plugin "^cpu$"
      PluginInstance "^[0-9]+$"
    </Match>
    <Target write>
      Plugin "aggregation"
    </Target>
    Target stop
  </Rule>
Target "write"
</Chain>

LoadPlugin python
<Plugin python>
  ModulePath "/usr/share/collectd"
  Import "testworkers"

</Plugin>
